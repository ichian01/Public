IF EXISTS(SELECT 1  FROM sys.procedures p INNER JOIN sys.schemas s on p.[schema_id] = s.[schema_id] WHERE p.[name] like 'sproc_PlaceNewOrder' and s.[name] like 'exchg' and p.type = 'P')
BEGIN
	DROP PROCEDURE exchg.sproc_PlaceNewOrder
END
GO
CREATE PROCEDURE exchg.sproc_PlaceNewOrder
(
	@user_id BIGINT,
	@instrument_id BIGINT,
	@is_bid BIT,--0 is offer,1 is bid
	@quantity DECIMAL(38,12),
	@price DECIMAL(38,12),--if it's market order we don't use this
	@price_currency_id BIGINT = 1,--hard-coding the id of instrument
	@is_market BIT = 0,--0 is limit order, 1 is market order
	@is_GTC BIT = 0,
	@is_AON BIT = 0,
	@is_IOC BIT = 0 --market orders are Immediate or Cancel, no spillovers
)
AS
BEGIN
	BEGIN TRANSACTION
		DECLARE @order_id bigint
		
		--First record the order
		INSERT INTO [exchg].[order]([user_id],[instrument_id],is_market,is_bid,quantity,price,price_currency_id,is_GTC)
		VALUES(@user_id,@instrument_id,@is_market,@is_bid,@quantity,@price,@price_currency_id,@is_GTC)
		SELECT @order_id = SCOPE_IDENTITY()
		
		--Market order
		--IF @is_market = 1
		--BEGIN
			--Get List of orders where @quantity < sum(quantity)
		--END
		--ELSE --Limit Order
		--BEGIN
		select * from exchg.order_book
		--END
		--update the outstanding order book
		--If order_id is not there, then we 
		INSERT INTO [exchg].[order_book](order_id,current_qty)
		VALUES(@order_id,@quantity)
	COMMIT
END
GO