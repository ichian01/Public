--Collection of SQL scripts to explore the metadata in SQL Server
--It used to be in sysobjects, but Microsoft has since included views that categorizes the data
--The advantage of reading the metadata from tables is that it can make table access simpler

--Gets a list of tables
select * from sys.tables

--Gets a list of primary key constraints, and list of columns given a specific table name
select pk.*, st.name, c.*
from sys.columns c join sys.tables t on c.object_id = t.object_id
join sys.systypes st on c.user_type_id = st.xusertype
left outer join sys.sysconstraints pk on pk.id = c.object_id and pk.status =133665 and pk.colid = c.column_id
where t.name = 'Table Name'
and default_object_id = 0

--Gets a list of columns
select c.*
from sys.columns c join sys.tables t on c.object_id = t.object_id
where t.name = 'Table Name'
and default_object_id = 0

--Gets a list of types
select * from sys.systypes

--Gets a list of primary key constraints
select sc.*,pk.* from sys.key_constraints pk join sys.sysconstraints sc on pk.object_id = sc.constid
where pk.type = 'PK'
and pk.parent_object_id = (select object_id from sys.tables where name = 'Table Names')
