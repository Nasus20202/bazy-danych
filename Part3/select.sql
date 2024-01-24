USE Stores;

-- 1.
-- Firma planuje zrobić podsumowanie roku. Ile średnio sklep zarobił na wszystkich
-- produktach w każdym miesiącu ubiegłego roku?
-- (Rozserzenie: klika lat zamiast 1)

DECLARE @StartYear INT = 2013
DECLARE @EndYear INT = 2023

SELECT SH.Name AS 'Shop name',
	DATENAME(MONTH, DATEADD(MONTH, MONTH(SA.Sale_date), 0 ) - 1 ) AS 'Month', 
	SUM(SA.Total_cost)/(@EndYear - @StartYear + 1) AS 'Average income [zł]',
	COUNT(SA.Sale_ID) AS 'Sales count'
	FROM SALES SA
	INNER JOIN Employees E ON E.Employee_ID = SA.Employee_ID
	INNER JOIN Shops SH ON SH.Shop_ID = E.Shop_ID
	WHERE YEAR(SA.Sale_date) BETWEEN @StartYear AND @EndYear
	GROUP BY SH.Name, MONTH(SA.Sale_date)
	ORDER BY SH.Name, MONTH(SA.Sale_date)



GO
-- 2.
-- Firma analizuje pewien produkt, kiedy jest największe zapotrzebowanie na niego
-- Uporządkuj miesiące (malejąco) według ilości sprzedanych produktu XXXX

DECLARE @ProductName NVARCHAR(512) = 'Mleko prosto od krowy';
SELECT DATENAME(MONTH, DATEADD(MONTH, MONTH(S.Sale_date), 0 ) - 1 ) AS 'Month',
	SUM(SD.Amount) AS 'Amount sold'
	FROM Sales S
	LEFT JOIN Sales_details SD ON SD.Sale_ID = S.Sale_ID
	WHERE SD.Product_ID = (SELECT Product_ID FROM Products P 
						WHERE P.Name = @ProductName)
	GROUP BY MONTH(S.Sale_date)
	ORDER BY SUM(SD.Amount) DESC, MONTH(S.Sale_date)





GO
-- 3.
-- Firm chce usprawnić branże X. Wyszukaj wszystkie produkty z branży X, które nie
-- przekroczyły N ilości sprzedaży.

DECLARE @Category NVARCHAR(512) = 'Artykuły spożywcze';
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
	ORDER BY SUM(SD.Amount)





GO
-- 4.
-- Pewien kupujący szuka na święta bożonarodzeniowe dla rodziny produktu, z
-- kategorii Y, którego sprzedano najwięcej w poprzednim grudniu
-- (Rozserzenie: klika lat zamiast 1)

DECLARE @Category NVARCHAR(512) = 'Artykuły domowe';
DECLARE @Month INT = 12; -- 12 for december
DECLARE @StartYear INT = 2013;
DECLARE @EndYear INT = 2023;

WITH Category_tree AS ( -- Category_tree: recursive query used to traverse through categories and all of its subcategories
	SELECT Category_ID AS ID, NAME AS N FROM Categories WHERE Categories.Name = @Category
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
	AND MONTH(S.Sale_date) = @Month AND YEAR(S.Sale_date) BETWEEN @StartYear AND @EndYear
	GROUP BY P.Product_ID, P.Name
	ORDER BY SUM(SD.Amount) DESC





GO
-- 5.
-- Klient, aby zwiększyć sprzedaż chce przekazać bonusowe punkty lojalnościowe
-- tym kupującym, którzy w ciągu ostatniego roku wydali X na zakupy w seci sklepów branżowych.
-- (modyfikacja: ostatnich 5 lat)

GO
CREATE VIEW Clients_stats_5y AS
	SELECT C.Client_ID, SUM(S.Total_cost) AS 'Total_spent', COUNT(S.Sale_ID) AS 'Sales_count', AVG(S.Total_cost) AS 'Average_cost' FROM Clients C
	INNER JOIN Sales S ON S.Client_ID = C.Client_ID
	WHERE S.Sale_date >= DATEADD(year, -5, GETDATE())
	GROUP BY C.Client_ID
GO

DECLARE @Threshold DECIMAL = 350.0;

SELECT C.Client_ID, C.Name, C.Surname, C.Email, CS.Total_spent, CS.Sales_count, CS.Average_cost,
	C.Points_collected, CAST(C.Points_collected*0.2 AS INT) AS 'Bonus points' FROM Clients C
	INNER JOIN Clients_stats_5y CS ON CS.Client_ID = C.Client_ID
	WHERE CS.Total_spent >= @Threshold
	ORDER BY CS.Total_spent DESC, Sales_count DESC

DROP VIEW Clients_stats_5y





GO
-- 6.
-- Sklep X przeprowadza remanent i chciałby poznać wartość wszystkich produktów
-- w swoich magazynach po aktualnego cenie sprzedaży.

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

DECLARE @ShopName NVARCHAR(512) = 'Sklep "Ropucha" Chojnice';

SELECT ROUND(SUM(Price * Amount), 2) AS 'Total value [zł]', @ShopName AS 'Shop name' FROM Products P
	INNER JOIN Current_prices CP ON CP.Product_ID = P.Product_ID
	INNER JOIN Storages S ON S.Product_ID = P.Product_ID
	WHERE S.Shop_ID = (SELECT Shop_ID FROM Shops WHERE Name = @ShopName);

DROP VIEW Current_prices




GO
-- 7.
-- Ilu produktów brakuje w magazynach sklepów? Policz, ile w każdym sklepie
-- jest produktów, których liczba w magazynie jest mniejsza niż 10.

DECLARE @Threshold INT = 10;
SELECT SH.Shop_ID, SH.Name, COUNT(P.Product_ID) AS 'Missing products' FROM Products P
	INNER JOIN Storages ST ON ST.Product_ID = P.Product_ID
	INNER JOIN Shops SH ON SH.Shop_ID = ST.Shop_ID
	WHERE Amount < @Threshold
	GROUP BY SH.Shop_ID, SH.Name
	ORDER BY COUNT(P.Product_ID) DESC




GO
-- 8.
-- Jaki produkt był najpopularniejszy w każdym ze sklepów? Wyświetl zestawienie
-- najczęciej sprzedawanego produktu w każdym ze sklepów.

WITH Products_sold AS (
	SELECT SH.Shop_ID, P.Product_ID, SUM(SD.Amount) AS 'Amount' FROM Products P
		INNER JOIN Sales_details SD ON SD.Product_ID = P.Product_ID
		INNER JOIN Sales S ON S.Sale_ID = SD.Sale_ID
		INNER JOIN Employees E ON E.Employee_ID = S.Employee_ID
		INNER JOIN Shops SH ON SH.Shop_ID = E.Shop_ID
		GROUP BY SH.Shop_ID, P.Product_ID
)
SELECT SH.Shop_ID, SH.Name, P.Product_ID, P.Name, PS.Amount FROM Products P
	INNER JOIN Products_sold PS ON PS.Product_ID = P.Product_ID
	INNER JOIN Shops SH ON SH.Shop_ID = PS.Shop_ID
	WHERE PS.Amount = (SELECT MAX(Amount) FROM Products_sold PS WHERE PS.Shop_ID = SH.Shop_ID)
	ORDER BY SH.Shop_ID, P.Product_ID




GO
-- 9.
-- Podaj rónice między najniższą a najwyższą ceną produktu?
-- Porównujemy wszystkie ceny danego produktu w bazie. Podaj także różnice procentowe

SELECT P.Product_ID, P.Name, MAX(PH.Price) AS 'Highest price', MIN(PH.Price) AS 'Lowest price', 
	MAX(PH.Price) - MIN(PH.Price) AS 'Price difference', 
	FORMAT((MIN(PH.Price) - MAX(PH.Price)) / MAX(PH.Price), 'P') AS 'Discount' FROM Products P
	INNER JOIN Price_histories PH ON PH.Product_ID = P.Product_ID
	GROUP BY P.Product_ID, P.Name
	ORDER BY MAX(PH.Price) - MIN(PH.Price) DESC