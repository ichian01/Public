IF EXISTS(SELECT 1  FROM sys.procedures p INNER JOIN sys.schemas s on p.[schema_id] = s.[schema_id] WHERE p.[name] like 'sproc_SetOrderAsFilled' and s.[name] like 'exchg' and p.type = 'P')
BEGIN
	DROP PROCEDURE exchg.sproc_SetOrderAsFilled
END
GO
CREATE PROCEDURE exchg.sproc_SetOrderAsFilled
(
	@order_id BIGINT
)
AS
BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON
	BEGIN TRANSACTION
			UPDATE exchg.[order]
			SET is_filled = 1,
				final_fill_time = SYSDATETIME()
			WHERE order_pk = @order_id

			--If an order is filled, make sure to delete it from order_book
			DELETE FROM exchg.[order_book] WHERE order_id = @order_id
	COMMIT
END