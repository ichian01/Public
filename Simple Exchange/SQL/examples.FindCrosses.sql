
--If an order exists in order, but not in order_book, then that's a dead order.
--If I store current quantity in order, for partial fills, then that uses more space


--Find crosses
select b.order_pk,b.is_bid,b.price,b.user_id,b.quantity,s.order_pk,s.is_bid,s.price,s.quantity,s.user_id
from exchg.[order] b join exchg.[order] s on b.is_bid = 0 and s.is_bid = 1 and b.instrument_id = s.instrument_id and b.price = s.price
WHERE b.is_filled = 0 AND s.is_filled = 0

select top 10 * from exchg.order_fill


	DECLARE @user_id BIGINT
	DECLARE @instrument_id BIGINT
	DECLARE @is_bid BIT
	DECLARE @quantity DECIMAL(38,12)
	DECLARE @price DECIMAL(38,12)

	SET @user_id = 2
	SET @instrument_id = 2
	SET @is_bid = 0--selling
	SET @quantity = 50
	SET @price = 1

	--This is a limit order.
	IF @is_bid = 1
	BEGIN
		SELECT *
		FROM exchg.[order] o JOIN exchg.[order_book] ob on o.order_pk = ob.order_id
		WHERE o.instrument_id = @instrument_id
		  AND o.is_bid = 0
		  AND o.price <= @price
		ORDER BY o.price ASC
	END
	ELSE
	BEGIN
		SELECT *
		FROM exchg.[order] o JOIN exchg.[order_book] ob on o.order_pk = ob.order_id
		WHERE o.instrument_id = @instrument_id
		  AND o.is_bid = 1
		  AND o.price >= @price
		ORDER BY o.price DESC
	END