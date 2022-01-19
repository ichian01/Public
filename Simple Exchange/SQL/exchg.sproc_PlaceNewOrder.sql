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
	SET NOCOUNT ON

	SET XACT_ABORT ON --rollback transaction on any errors

	BEGIN TRANSACTION
		DECLARE @order_id bigint
		DECLARE @is_filled bit
		SET @is_filled = 0
		
		--First record the order
		INSERT INTO [exchg].[order]([user_id],[instrument_id],is_market,is_bid,quantity,price,price_currency_id,is_GTC)
		VALUES(@user_id,@instrument_id,@is_market,@is_bid,@quantity,@price,@price_currency_id,@is_GTC)
		SELECT @order_id = SCOPE_IDENTITY()
		
		INSERT INTO [exchg].[order_book](order_id,current_qty)
		VALUES(@order_id,@quantity)

		--https://www.mssqltips.com/sqlservertip/6148/sql-server-loop-through-table-rows-without-cursor/
		--Fill the order, recursively
		EXEC exchg.sproc_FillOrder @order_id

	COMMIT
END
GO