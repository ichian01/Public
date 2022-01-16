IF EXISTS(SELECT 1  FROM sys.procedures p INNER JOIN sys.schemas s on p.[schema_id] = s.[schema_id] WHERE p.[name] like 'sproc_GetOrderBook' and s.[name] like 'exchg' and p.type = 'P')
BEGIN
	DROP PROCEDURE exchg.sproc_GetOrderBook
END
GO
CREATE PROCEDURE exchg.sproc_GetOrderBook
(
	@instrument_id BIGINT,
	@currency_id BIGINT = 1,
	@level INT = 3
)
AS
BEGIN
	IF @level = 1
	BEGIN
		DECLARE @maxBidPrice decimal(38,12)
		DECLARE @minOfferPrice decimal(38,12)

		SELECT @maxBidPrice = max(o.price)
		FROM exchg.[order_book] ob JOIN exchg.[order] o on ob.order_id = o.order_pk
		WHERE o.instrument_id = @instrument_id
		  AND o.price_currency_id = @currency_id
		  AND o.is_bid = 1
		  AND o.is_filled = 0
		
		SELECT @minOfferPrice = min(o.price)
		FROM exchg.[order_book] ob JOIN exchg.[order] o on ob.order_id = o.order_pk
		WHERE o.instrument_id = @instrument_id
		  AND o.price_currency_id = @currency_id
		  AND o.is_bid = 0
		  AND o.is_filled = 0

		SELECT	o.is_bid,
				o.price,
				[current_qty] = SUM(ob.current_qty),
				[order_count] = count(o.order_pk)
		FROM exchg.[order_book] ob JOIN exchg.[order] o on ob.order_id = o.order_pk
		WHERE o.instrument_id = @instrument_id
		  AND o.price_currency_id = @currency_id
		  AND o.is_filled = 0
		  AND ((o.is_bid = 1 AND o.price = @maxBidPrice) OR (o.is_bid = 0 AND o.price = @minOfferPrice))
		GROUP BY o.is_bid, o.price
		ORDER BY o.price DESC
	END
	ELSE IF @level=2
	BEGIN
		SELECT	o.is_bid,
				o.price,
				[current_qty] = SUM(ob.current_qty),
				[order_count] = count(o.order_pk)
		FROM exchg.[order_book] ob JOIN exchg.[order] o on ob.order_id = o.order_pk
		WHERE o.instrument_id = @instrument_id
		  AND o.price_currency_id = @currency_id
		  AND o.is_filled = 0
		GROUP BY o.is_bid, o.price
		ORDER BY o.price DESC
	END
	ELSE
	BEGIN
		SELECT	o.is_bid,
				o.price,
				ob.current_qty,
				o.order_pk,
		FROM exchg.[order_book] ob JOIN exchg.[order] o on ob.order_id = o.order_pk
		WHERE o.instrument_id = @instrument_id
		  AND o.price_currency_id = @currency_id
		  AND o.is_filled = 0
		ORDER BY o.price desc
	END
END
GO
--EXEC exchg.sproc_GetOrderBook 2