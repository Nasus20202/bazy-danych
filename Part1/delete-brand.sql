USE Stores;

DECLARE @brand_id INT = 20;
DECLARE @products TABLE (Product_ID INT);

INSERT INTO @products SELECT Product_ID FROM Products WHERE Brand_ID = @brand_id;

SELECT Products.* FROM Products JOIN @products TMP ON Products.Product_ID = TMP.Product_ID;

DELETE FROM Brands WHERE Brand_ID = @brand_id;
SELECT 'Brand with ID ' + CAST(@brand_id AS VARCHAR) + ' was deleted' AS Message;

SELECT Products.* FROM Products JOIN @products TMP ON Products.Product_ID = TMP.Product_ID;