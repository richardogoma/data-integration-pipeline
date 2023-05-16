# --------------------------------
-- Run these to confirm data loaded to database table
select name from sys.databases;
go

use testdb;
go 

select name from sys.tables;
go

select top 5 first_name from mock_data;
go

