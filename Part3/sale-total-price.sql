USE Stores;

SELECT S.Sale_ID, ROUND(SUM(PH.Price*SD.Amount), 2) FROM Sales S
	JOIN Sales_details SD ON S.Sale_ID = SD.Sale_ID
	JOIN Products P ON SD.Product_ID = P.Product_ID
	JOIN Price_histories PH ON P.Product_ID = PH.Product_ID
	AND PH.Start_date = (SELECT MAX(Start_date) FROM Price_histories
			WHERE Product_ID=P.Product_ID
			AND Start_date <= S.Sale_date)
	GROUP BY S.Sale_ID