USE Stores;

-- 1.
-- Firma planuje zrobiæ podsumowanie roku. Ile œrednio sklep zarobi³ na wszystkich
-- produktach w ka¿dym miesi¹cu ubieg³ego roku?
-- (Rozserzenie: klika lat zamiast 1)

DECLARE @StartYear INT = 2019
DECLARE @EndYear INT = 2023
SELECT DATENAME(MONTH, DATEADD(MONTH, MONTH(S.Sale_date), 0 ) - 1 ) AS 'Month', 
	SUM(S.Total_cost)/(@EndYear-@StartYear+1) AS 'Average income [z³]'
	FROM SALES S
	WHERE YEAR(S.Sale_date) >= @StartYear AND YEAR(S.Sale_date) <= @EndYear
	GROUP BY MONTH(S.Sale_date)
	ORDER BY MONTH(S.Sale_date)

-- 2.
-- Firma analizuje pewien produkt, kiedy jest najwiêksze zapotrzebowanie na niego
-- Uporz¹dkuj miesi¹ce (malej¹co) wed³ug iloœci sprzedanych produktu XXXX

DECLARE @ProductName NVARCHAR(512) = 'Mleko prosto od krowy';
SELECT DATENAME(MONTH, DATEADD(MONTH, MONTH(S.Sale_date), 0 ) - 1 ) AS 'Month',
	SUM(SD.Amount) AS 'Amount sold'
	FROM Sales S
	LEFT JOIN Sales_details SD ON SD.Sale_ID = S.Sale_ID
	WHERE SD.Product_ID = (SELECT Product_ID FROM Products P 
						WHERE P.Name = @ProductName)
	GROUP BY MONTH(S.Sale_date)
	ORDER BY SUM(SD.Amount) DESC, MONTH(S.Sale_date)


-- 3.
-- Firm chce usprawniæ bran¿e X. Wyszukaj wszystkie produkty z bran¿y X, które nie
-- przekroczy³y N iloœci sprzeda¿y.

DECLARE @Category NVARCHAR(512) = 'Artyku³y spo¿ywcze';
DECLARE @Threshold INT = 100;

WITH Category_tree AS ( -- Category_tree: recursive query used to traverse through categories and all of its subcategories
	SELECT Category_ID AS ID, NAME AS N FROM Categories WHERE Categories.Name = @Category
		UNION ALL
		SELECT Category_ID, NAME FROM Category_tree, Categories
		WHERE Category_tree.ID = Categories.Parent_ID
)
SELECT P.Product_ID, P.Name, SUM(SD.Amount) AS 'Total sold' FROM Products P
	INNER JOIN Categories C ON P.Category_ID = C.Category_ID
	INNER JOIN Sales_details SD ON SD.Product_ID = P.Product_ID
	INNER JOIN Sales S ON S.Sale_ID = SD.Sale_ID
	WHERE P.Product_ID IN (
		SELECT Product_ID FROM Products
			INNER JOIN Categories ON Products.Category_ID = Categories.Category_ID
			WHERE Products.Category_ID IN (SELECT ID FROM Category_tree)
	)
	GROUP BY P.Product_ID, P.Name
	HAVING SUM(SD.Amount) <= @Threshold
