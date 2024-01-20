USE Stores;

-- 1.
-- Firma planuje zrobiæ podsumowanie roku. Ile œrednio sklep zarobi³ na wszystkich
-- produktach w ka¿dym miesi¹cu ubieg³ego roku?
-- (Rozserzenie: klika lat zamiast 1)

DECLARE @StartYear1 INT = 2019
DECLARE @EndYear1 INT = 2023
SELECT DATENAME(MONTH, DATEADD(MONTH, MONTH(S.Sale_date), 0 ) - 1 ) AS 'Month', 
	SUM(S.Total_cost)/(@EndYear1-@StartYear1+1) AS 'Average income [z³]'
	FROM SALES S
	WHERE YEAR(S.Sale_date) >= @StartYear1 AND YEAR(S.Sale_date) BETWEEN @StartYear1 AND @EndYear1
	GROUP BY MONTH(S.Sale_date)
	ORDER BY MONTH(S.Sale_date)






-- 2.
-- Firma analizuje pewien produkt, kiedy jest najwiêksze zapotrzebowanie na niego
-- Uporz¹dkuj miesi¹ce (malej¹co) wed³ug iloœci sprzedanych produktu XXXX

DECLARE @ProductName2 NVARCHAR(512) = 'Mleko prosto od krowy';
SELECT DATENAME(MONTH, DATEADD(MONTH, MONTH(S.Sale_date), 0 ) - 1 ) AS 'Month',
	SUM(SD.Amount) AS 'Amount sold'
	FROM Sales S
	LEFT JOIN Sales_details SD ON SD.Sale_ID = S.Sale_ID
	WHERE SD.Product_ID = (SELECT Product_ID FROM Products P 
						WHERE P.Name = @ProductName2)
	GROUP BY MONTH(S.Sale_date)
	ORDER BY SUM(SD.Amount) DESC, MONTH(S.Sale_date)







-- 3.
-- Firm chce usprawniæ bran¿e X. Wyszukaj wszystkie produkty z bran¿y X, które nie
-- przekroczy³y N iloœci sprzeda¿y.

DECLARE @Category3 NVARCHAR(512) = 'Artyku³y spo¿ywcze';
DECLARE @Threshold3 INT = 100;

WITH Category_tree AS ( -- Category_tree: recursive query used to traverse through categories and all of its subcategories
	SELECT Category_ID AS ID, NAME AS N FROM Categories WHERE Categories.Name = @Category3
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
	HAVING SUM(SD.Amount) <= @Threshold3
	ORDER BY SUM(SD.Amount)






-- 4.
-- Pewien kupuj¹cy szuka na œwiêta bo¿onarodzeniowe dla rodziny produktu, z
-- kategorii Y, którego sprzedano najwiêcej w poprzednim grudniu
-- (Rozserzenie: klika lat zamiast 1)

DECLARE @Category4 NVARCHAR(512) = 'Artyku³y domowe';
DECLARE @Month4 INT = 12; -- 12 for december
DECLARE @StartYear4 INT = 2013;
DECLARE @EndYear4 INT = 2023;

WITH Category_tree AS ( -- Category_tree: recursive query used to traverse through categories and all of its subcategories
	SELECT Category_ID AS ID, NAME AS N FROM Categories WHERE Categories.Name = @Category4
		UNION ALL
		SELECT Category_ID, NAME FROM Category_tree, Categories
		WHERE Category_tree.ID = Categories.Parent_ID
)
SELECT TOP 1 P.Product_ID, P.Name, SUM(SD.Amount) AS 'Total sold' FROM Products P
	INNER JOIN Categories C ON P.Category_ID = C.Category_ID
	INNER JOIN Sales_details SD ON SD.Product_ID = P.Product_ID
	INNER JOIN Sales S ON S.Sale_ID = SD.Sale_ID
	WHERE P.Product_ID IN (
		SELECT Product_ID FROM Products
			INNER JOIN Categories ON Products.Category_ID = Categories.Category_ID
			WHERE Products.Category_ID IN (SELECT ID FROM Category_tree)
	) 
	AND MONTH(S.Sale_date) = @Month4 AND YEAR(S.Sale_date) BETWEEN @StartYear4 AND @EndYear4
	GROUP BY P.Product_ID, P.Name
	ORDER BY SUM(SD.Amount) DESC







-- 5.
-- Klient, aby zwiêkszyæ sprzeda¿ chce daæ przekazaæ bonusowe punkty lojalnoœciowe
-- tym kupuj¹cym którzy w ci¹gu ostatniego roku wydali X na zakupy w seci sklepów bran¿owych.
-- (modyfikacja: ostatnich 5 lat)

GO
CREATE VIEW Clients_stats_5y AS
	SELECT C.Client_ID, SUM(S.Total_cost) AS 'Total_spent', COUNT(S.Sale_ID) AS 'Sales_count', AVG(S.Total_cost) AS 'Average_cost' FROM Clients C
	INNER JOIN Sales S ON S.Client_ID = C.Client_ID
	WHERE S.Sale_date >= DATEADD(year, -5, GETDATE())
	GROUP BY C.Client_ID
GO

SELECT TOP 100 C.Client_ID, C.Name, C.Surname, C.Email, CS.Total_spent, CS.Sales_count, CS.Average_cost,
	C.Points_collected, CAST(C.Points_collected*0.2 AS INT) AS 'Bonus points' FROM Clients C
	INNER JOIN Clients_stats_5y CS ON CS.Client_ID = C.Client_ID
	ORDER BY CS.Total_spent DESC, Sales_count DESC

DROP VIEW Clients_stats_5y








-- 6.
-- Sklep X przeprowadza remanent i chcia³bym poznaæ wartoœæ wszystkich produktów
-- w swoich magazynach po aktualnego cenie sprzeda¿y.

GO
CREATE VIEW Current_prices AS
WITH Last_update AS ( -- returns last time the price of the product was changed before now
	SELECT Product_ID, MAX(Start_date) AS 'Last_update' FROM Price_histories
	WHERE Start_date <= GETDATE()
	GROUP BY Product_ID
)
SELECT PH.Product_ID, PH.Price FROM Price_histories PH
	INNER JOIN Last_update LU ON PH.Product_ID = LU.Product_ID
	WHERE LU.Last_update = PH.Start_date
GO

DECLARE @ShopName6 NVARCHAR(512) = 'Sklep "Ropucha" Chojnice';

SELECT ROUND(SUM(Price * Amount), 2) AS 'Total value [z³]', @ShopName6 AS 'Shop name' FROM Products P
	INNER JOIN Current_prices CP ON CP.Product_ID = P.Product_ID
	INNER JOIN Storages S ON S.Product_ID = P.Product_ID
	WHERE S.Shop_ID = (SELECT Shop_ID FROM Shops WHERE Name = @ShopName6);

DROP VIEW Current_prices






