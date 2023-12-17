USE Stores;

DECLARE @SaleId INT = 10;
DECLARE @ClientId INT = (SELECT Client_ID FROM Sales WHERE Sale_ID = @SaleId);

SELECT * FROM Clients WHERE Client_ID = @ClientId;
SELECT * FROM Sales WHERE Sale_ID = @SaleId;

DELETE FROM Clients WHERE Client_ID = @ClientId;
SELECT 'Client with ID ' + CAST(@ClientId AS VARCHAR) + ' was deleted' AS Message;

SELECT * FROM Clients WHERE Client_ID = @ClientId;
SELECT * FROM Sales WHERE Sale_ID = @SaleId;