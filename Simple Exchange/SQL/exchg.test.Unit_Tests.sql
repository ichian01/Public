DECLARE @user_id bigint
DECLARE @instrument_id bigint

SELECT @user_id = u.[user_pk] FROM exchg.[user] u WHERE u.[user_name] like 'Bob'
SELECT @instrument_id = u.[instrument_pk] FROM exchg.[instrument] u WHERE u.[instrument_name] like 'CatCoin'

DELETE exchg.order_book
DELETE exchg.[order]
--bid 100 CatCoins for $1
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, 1, 100, 1
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, 1, 100, 1
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, 0, 100, 3

SELECT @user_id = u.[user_pk] FROM exchg.[user] u WHERE u.[user_name] like 'Alice'
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, 1, 100, 1
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, 1, 100, 0.5
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, 0, 100, 4


EXEC exchg.sproc_GetOrderBook 2, 2

select * from exchg.[order]