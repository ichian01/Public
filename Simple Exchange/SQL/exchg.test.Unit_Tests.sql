
EXEC exchg.sproc_GetOrderBook 2, @level=1
EXEC exchg.sproc_GetOrderBook 2, @level=2
EXEC exchg.sproc_GetOrderBook 2, @level=3


DECLARE @user_id bigint
DECLARE @instrument_id bigint

SELECT @user_id = u.[user_pk] FROM exchg.[user] u WHERE u.[user_name] like 'Bob'
SELECT @instrument_id = u.[instrument_pk] FROM exchg.[instrument] u WHERE u.[instrument_name] like 'CatCoin'

EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, @is_bid=1, @quantity=20, @price=7, @is_market = 1

select * from exchg.[order]
select * from exchg.[order_book] order by order_id