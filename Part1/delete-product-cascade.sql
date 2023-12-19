USE Stores;

DECLARE @product_id INT = 10;

SELECT * FROM Products WHERE Product_ID = @product_id;
SELECT * FROM Price_histories WHERE Product_ID = @product_id;

DECLARE @ph_count_before INT = (SELECT COUNT(*) FROM Price_histories);
DECLARE @sd_count_before INT = (SELECT COUNT(*) FROM Sales_details);
DECLARE @st_count_before INT = (SELECT COUNT(*) FROM Storages);


DELETE FROM Products WHERE Product_ID = @product_id;
SELECT 'Product with ID ' + CAST(@product_id AS VARCHAR) + ' was deleted' AS Message;


SELECT * FROM Products WHERE Product_ID = @product_id;
SELECT * FROM Price_histories WHERE Product_ID = @product_id;

DECLARE @ph_count_after INT = (SELECT COUNT(*) FROM Price_histories);
DECLARE @sd_count_after INT = (SELECT COUNT(*) FROM Sales_details);
DECLARE @st_count_after INT = (SELECT COUNT(*) FROM Storages);

SELECT 'Count before: ' + CAST(@ph_count_before AS VARCHAR) + ', after: ' + CAST(@ph_count_after AS VARCHAR) AS Product_histories,
	   'Count before: ' + CAST(@sd_count_before AS VARCHAR) + ', after: ' + CAST(@sd_count_after AS VARCHAR) AS Sales_details,
	   'Count before: ' + CAST(@st_count_before AS VARCHAR) + ', after: ' + CAST(@st_count_after AS VARCHAR) AS Storages;