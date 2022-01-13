---Orders come in and we create our order book
--If the order book exists check to see if the new order is a taking order
--

--Features
--Add New Order
--Partial Fills
--Spillover fills, if my order is so large that it fills part of the book and creates a new standing order
--If there's a spillover fill, we fill, then cancel the original order, and create a new one that remains.
--Level 3 order book, level 2 and level 1 are just aggregates
--cancel standing order
--Modify Order is same as a cancel and a new order

--IOC, AON, FOK
--IOC means no spillover fills
--AON means no partials
--FOK is both, no spillovers and no partials.


--Canceling an order
--removes the entry from current order_book

--cancel all outstanding orders

--CREATE SCHEMA [exchg]
--GO

IF EXISTS(SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.[schema_id] = s.[schema_id] WHERE s.[name] LIKE 'exchg' AND t.[name] LIKE 'order_fill' AND [type] = 'U')
BEGIN
	DROP TABLE [exchg].order_fill
END

IF EXISTS(SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.[schema_id] = s.[schema_id] WHERE s.[name] LIKE 'exchg' AND t.[name] LIKE 'cancel_order' AND [type] = 'U')
BEGIN
	DROP TABLE [exchg].cancel_order
END

IF EXISTS(SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.[schema_id] = s.[schema_id] WHERE s.[name] LIKE 'exchg' AND t.[name] LIKE 'order_book' AND [type] = 'U')
BEGIN
	DROP TABLE [exchg].order_book
END

IF EXISTS(SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.[schema_id] = s.[schema_id] WHERE s.[name] LIKE 'exchg' AND t.[name] LIKE 'order' AND [type] = 'U')
BEGIN
	DROP TABLE [exchg].[order]
END

IF EXISTS(SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.[schema_id] = s.[schema_id] WHERE s.[name] LIKE 'exchg' AND t.[name] LIKE 'user' AND [type] = 'U')
BEGIN
	DROP TABLE [exchg].[user]
END

IF EXISTS(SELECT 1 FROM sys.tables t JOIN sys.schemas s ON t.[schema_id] = s.[schema_id] WHERE s.[name] LIKE 'exchg' AND t.[name] LIKE 'instrument' AND [type] = 'U')
BEGIN
	DROP TABLE [exchg].[instrument]
END
GO

CREATE TABLE [exchg].[user]
(
	user_pk BIGINT IDENTITY(1,1) NOT NULL,
	[user_name]  NVARCHAR(32)  NOT NULL,
	CONSTRAINT PK_user PRIMARY KEY (user_pk),
	CONSTRAINT UC_user_name UNIQUE ([user_name])
)

CREATE TABLE [exchg].[instrument]
(
	instrument_pk BIGINT IDENTITY(1,1) NOT NULL,
	instrument_name NVARCHAR(32) NOT NULL,
	CONSTRAINT PK_instrument PRIMARY KEY (instrument_pk),
	CONSTRAINT UC_instrument_name UNIQUE ([instrument_name])
)

--update the order if it's canceled
--else always insert
CREATE TABLE [exchg].[order]
(
	order_pk BIGINT NOT NULL IDENTITY(1,1),
	order_entry_time DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
	[user_id] BIGINT NOT NULL,
	instrument_id BIGINT NOT NULL,
	is_market BIT NOT NULL DEFAULT 0,--0 is limit order, 1 is market order
	is_bid BIT NOT NULL DEFAULT 0,--0 is offer, 1 is bid
	quantity DECIMAL(38,12) NOT NULL,
	price DECIMAL(38,12) NOT NULL,
	is_GTC BIT NOT NULL DEFAULT 0,
	is_canceled BIT NOT NULL DEFAULT 0, --just for easy state management
	is_filled  BIT NOT NULL DEFAULT 0, 
	first_fill_time DATETIME2 NULL,--just for easy state management
	final_fill_time DATETIME2 NULL,
	canceled_time DATETIME2 NULL,
	CONSTRAINT PK_order PRIMARY KEY (order_pk),
	CONSTRAINT FK_user FOREIGN KEY ([user_id]) REFERENCES [exchg].[user](user_pk),
	CONSTRAINT FK_instrument FOREIGN KEY (instrument_id) REFERENCES [exchg].[instrument](instrument_pk)
)

CREATE TABLE [exchg].[order_book]
(
	order_id BIGINT NOT NULL,
	current_qty DECIMAL(38,12) NOT NULL, --bitcoin is 10^-8, mwei is 10^-12
	CONSTRAINT FK_live_order FOREIGN KEY (order_id) REFERENCES [exchg].[order](order_pk),
	CONSTRAINT UC_live_order_id UNIQUE ([order_id])--This creates a 1:1 relationship, but we only care about live orders
)

--extra recording
CREATE TABLE [exchg].[cancel_order]
(
	order_id BIGINT NOT NULL,
	cancel_entry_time DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
	CONSTRAINT FK_cancel_order FOREIGN KEY (order_id) REFERENCES [exchg].[order](order_pk),
	CONSTRAINT UC_cancel_order_id UNIQUE ([order_id])--This creates a 1:1 relationship
)

--new order comes in and if there are matches, we fill this out
CREATE TABLE [exchg].[order_fill]
(
	maker_order_id BIGINT NOT NULL,
	taker_order_id BIGINT NOT NULL,
	fill_quantity DECIMAL(38,12) NOT NULL,
	fill_entry_time DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
	CONSTRAINT FK_maker FOREIGN KEY (maker_order_id) REFERENCES [exchg].[order](order_pk),
	CONSTRAINT FK_taker FOREIGN KEY (taker_order_id) REFERENCES [exchg].[order](order_pk)
)
GO
--From here we can figure out each user's trades
--and each user's positions
--as well as track tax-lots
--from there we can figure out simple P&L, and balance sheet.