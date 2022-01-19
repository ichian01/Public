IF EXISTS(SELECT 1  FROM sys.procedures p INNER JOIN sys.schemas s on p.[schema_id] = s.[schema_id] WHERE p.[name] like 'sproc_FillOrder' and s.[name] like 'exchg' and p.type = 'P')
BEGIN
	DROP PROCEDURE exchg.sproc_FillOrder
END
GO
CREATE PROCEDURE exchg.sproc_FillOrder
(
	@taker_order_id BIGINT
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @taker_quantity decimal(38,12)
	DECLARE @instrument_id bigint
	DECLARE @currency_id bigint
	DECLARE @is_bid bit
	DECLARE @limitPrice decimal(38,12)
	DECLARE @is_market bit

	SELECT @taker_quantity = isnull(ob.current_qty,o.quantity),
		   @instrument_id = o.instrument_id,
		   @currency_id = o.price_currency_id, 
		   @is_bid = o.is_bid,
		   @limitPrice = o.price,
		   @is_market = o.is_market
	FROM exchg.order_book ob RIGHT OUTER JOIN exchg.[order] o on ob.order_id = o.order_pk
	WHERE o.order_pk = @taker_order_id
	  AND o.is_filled = 0
	  AND o.is_canceled = 0
	
	--If it's a market order, set limitprice to null
	IF @is_market = 1
	BEGIN
		SET @limitPrice = NULL
	END

	DECLARE @maker_order_id bigint
	DECLARE @maker_quantity decimal(38,12)
	PRINT 'FillLimit Called'
	--taker is buyer
	IF (@is_bid = 1)
	BEGIN
		PRINT 'FillLimit Buyer'
		SELECT TOP 1 @maker_order_id = ob.order_id, @maker_quantity = ob.current_qty
		FROM exchg.order_book ob join exchg.[order] o on ob.order_id = o.order_pk
		WHERE o.is_bid = ~@is_bid
		 AND o.price_currency_id = @currency_id
		 AND o.instrument_id = @instrument_id
		 AND (@limitPrice is null OR o.price <= @limitPrice) --buy best price, cheaper is better
		ORDER BY o.price ASC, order_pk ASC
	END
	ELSE IF (@is_bid = 0)--taker is seller
	BEGIN
		PRINT 'FillLimit Seller'
		SELECT TOP 1 @maker_order_id = ob.order_id, @maker_quantity = ob.current_qty
		FROM exchg.order_book ob join exchg.[order] o on ob.order_id = o.order_pk
		WHERE o.is_bid = ~@is_bid
		 AND o.price_currency_id = @currency_id
		 AND o.instrument_id = @instrument_id
		 AND (@limitPrice is null OR o.price >= @limitPrice) --sell best price, higher is better
		ORDER BY o.price DESC, order_pk ASC		
	END
	ELSE
	BEGIN
		PRINT 'ORDER NOT FOUND'
	END

	IF (@maker_order_id IS NOT NULL)
	BEGIN
		PRINT 'FillLimit Match Found'
		--If this is the first fill, update both order's timestamp
		UPDATE exchg.[order]
		SET first_fill_time = SYSDATETIME()
		WHERE (order_pk = @maker_order_id OR order_pk = @taker_order_id)
		  AND first_fill_time IS NULL

		--If partial fill for maker
		IF @maker_quantity > @taker_quantity
		BEGIN
			--Fill the taker's total order
			INSERT INTO exchg.order_fill(maker_order_id,taker_order_id,fill_quantity)
			VALUES(@maker_order_id, @taker_order_id, @taker_quantity)

			--Remove the taker from the book
			exec exchg.sproc_SetOrderAsFilled @taker_order_id

			--Update our live order book and decrease the maker's current quantity
			UPDATE exchg.order_book
			SET current_qty = @maker_quantity - @taker_quantity
			WHERE order_id = @maker_order_id
		END
		ELSE --the maker order is smaller or same as the taker
		BEGIN

			--Fill the maker's total order
			INSERT INTO exchg.order_fill(maker_order_id,taker_order_id,fill_quantity)
			VALUES(@maker_order_id, @taker_order_id, @maker_quantity)
			
			--Remove the maker from the book
			exec exchg.sproc_SetOrderAsFilled @maker_order_id

			--Use Recursion to fill if there's any left
			IF @maker_quantity < @taker_quantity
			BEGIN
				IF NOT EXISTS(SELECT 1 FROM exchg.order_book WHERE order_id = @taker_order_id)
				BEGIN
					INSERT exchg.order_book(order_id,current_qty)
					VALUES(@taker_order_id,@taker_quantity - @maker_quantity)
				END
				ELSE
				BEGIN
					--Update our live order book and decrease the maker's current quantity
					UPDATE exchg.order_book
					SET current_qty = @taker_quantity - @maker_quantity
					WHERE order_id = @taker_order_id
				END

				EXEC exchg.sproc_FillOrder @taker_order_id
			END
		END
	END
END
GO