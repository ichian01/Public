DECLARE @user_id bigint
DECLARE @instrument_id bigint

SELECT @user_id = u.[user_pk] FROM exchg.[user] u WHERE u.[user_name] like 'Bob'
SELECT @instrument_id = u.[instrument_pk] FROM exchg.[instrument] u WHERE u.[instrument_name] like 'CatCoin'


--bid 100 CatCoins for $1
EXEC exchg.sproc_PlaceNewOrder @user_id, @instrument_id, 0, 1, 100, 1