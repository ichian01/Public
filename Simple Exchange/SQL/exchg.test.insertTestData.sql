

INSERT INTO [exchg].[user]([user_name])
VALUES('Bob')
INSERT INTO [exchg].[user]([user_name])
VALUES('Alice')

INSERT INTO [exchg].[instrument]([instrument_name])
VALUES('CatCoin')
INSERT INTO [exchg].[instrument]([instrument_name])
VALUES('MouseCoin')

DECLARE @user_id bigint
DECLARE @instrument_id bigint

SELECT @user_id = u.[user_pk] FROM exchg.[user] u WHERE u.[user_name] like 'Bob'
SELECT @instrument_id = u.[instrument_pk] FROM exchg.[instrument] u WHERE u.[instrument_name] like 'CatCoin'

DELETE exchg.order_book
DELETE exchg.[order]
--Bob makes a market on CatCoin, some bids, and some offers
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=1, @quantity=100, @price=2
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=1, @quantity=50, @price=2
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=1, @quantity=30, @price=2.5
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=1, @quantity=50, @price=4
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=1, @quantity=5, @price=4
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=0, @quantity=5, @price=7
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=0, @quantity=10, @price=8
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=0, @quantity=20, @price=10
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=0, @quantity=55, @price=20

--Alice makes an order book too
SELECT @user_id = u.[user_pk] FROM exchg.[user] u WHERE u.[user_name] like 'Alice'
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=1, @quantity=5000, @price=0.25
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=1, @quantity=100, @price=2
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=1, @quantity=25, @price=3
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=1, @quantity=25, @price=4
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=0, @quantity=15, @price=7
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=0, @quantity=25, @price=7.5
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=0, @quantity=500, @price=200


EXEC exchg.sproc_GetOrderBook 2, @level=3

EXEC exchg.sproc_PlaceNewOrder @user_id=1, @instrument_id=2, @is_bid=1, @quantity=3, @price=7

EXEC exchg.sproc_FillLimitOrder 19

select * from exchg.[order]
select * from exchg.[order_fill]

	SELECT ob.current_qty,
		   o.instrument_id,
		   o.price_currency_id, 
		   o.is_bid,
		   o.price
	FROM exchg.order_book ob right outer join exchg.[order] o on ob.order_id = o.order_pk
	WHERE o.order_pk = 17
	  AND o.is_filled = 0
	  AND o.is_canceled = 0