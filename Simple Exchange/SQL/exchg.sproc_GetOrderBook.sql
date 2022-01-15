IF EXISTS(SELECT 1  FROM sys.procedures p INNER JOIN sys.schemas s on p.[schema_id] = s.[schema_id] WHERE p.[name] like 'sproc_GetOrderBook' and s.[name] like 'exchg' and p.type = 'P')
BEGIN
	DROP PROCEDURE exchg.sproc_GetOrderBook
END
GO
CREATE PROCEDURE exchg.sproc_GetOrderBook
(
	@instrument_id BIGINT,
	@levels INT = 3
)
AS
BEGIN
	IF @levels = 1
	BEGIN
		SELECT TOP 1 ob.current_qty, o.*
		FROM exchg.[order_book] ob JOIN exchg.[order] o on ob.order_id = o.order_pk
		WHERE o.instrument_id = @instrument_id
		  AND o.is_bid = 1
		  AND o.is_filled = 0
		ORDER BY o.price desc
		
		SELECT TOP 1 ob.current_qty, o.*
		FROM exchg.[order_book] ob JOIN exchg.[order] o on ob.order_id = o.order_pk
		WHERE o.instrument_id = @instrument_id
		  AND o.is_bid = 0
		  AND o.is_filled = 0
		ORDER BY o.price asc
	END
	ELSE IF @levels=2
	BEGIN
		SELECT [current_qty]=SUM(ob.current_qty),
			   [order_count] = count(o.order_pk),
				o.is_bid,
				o.price
		FROM exchg.[order_book] ob JOIN exchg.[order] o on ob.order_id = o.order_pk
		WHERE o.instrument_id = @instrument_id
		  AND o.is_filled = 1
		GROUP BY o.is_bid, o.price
		ORDER BY o.price DESC
	END
	ELSE
	BEGIN
		SELECT ob.current_qty, o.*
		FROM exchg.[order_book] ob JOIN exchg.[order] o on ob.order_id = o.order_pk
		WHERE o.instrument_id = @instrument_id
		  AND o.is_filled = 1
		ORDER BY o.price desc
	END
END
GO
--EXEC exchg.sproc_GetOrderBook 2