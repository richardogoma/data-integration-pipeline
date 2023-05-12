GO
-- ================Metadata
SELECT * FROM sys.tables;
GO

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS;
GO

SELECT * 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS;
GO

SELECT * 
FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE;
GO

select c.column_id, c.name, c.is_nullable
from sys.columns c
WHERE c.object_id = OBJECT_ID('dbo.Table1');
GO

-- Auto Generate Update Statement (Per column)
DECLARE @ColumnName nvarchar(255)
DECLARE @SQL nvarchar(max)

DECLARE ColumnCursor CURSOR FOR
    SELECT c.name
    FROM sys.columns c
    WHERE c.object_id = OBJECT_ID('dbo.Table1') and c.name <> 'ID'

OPEN ColumnCursor

FETCH NEXT FROM ColumnCursor INTO @ColumnName

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'UPDATE Table1
                SET ' + @ColumnName + ' = Table2.' + @ColumnName + '
                FROM Table1
                INNER JOIN Table2
                ON Table1.ID = Table2.ID;'

    PRINT @SQL

    FETCH NEXT FROM ColumnCursor INTO @ColumnName
END

CLOSE ColumnCursor
DEALLOCATE ColumnCursor

-- Auto Generate Update Statement (Normal)
DECLARE @SQL nvarchar(max)

SET @SQL = 'UPDATE [dbo].[$(TableName)]
SET '

SELECT @SQL = @SQL + c.name + ' = t.' + c.name + ', '
FROM sys.columns c
WHERE c.object_id = OBJECT_ID('[dbo].[$(TableName)]') and c.name <> 'ID'

SET @SQL = LEFT(@SQL, LEN(@SQL) - 1) + '
FROM [dbo].[$(TableName)] p
INNER JOIN [dbo].[temp_$(TableName)] t
ON p.$(PrimaryKey) = t.$(PrimaryKey);'

PRINT @SQL
EXEC sp_executesql @SQL

-- Affected rows by DML
CREATE TABLE Table1 (
    ID INT PRIMARY KEY,
    Column1 TEXT
);
GO
CREATE TABLE Table2 (
    ID INT PRIMARY KEY,
    Column1 TEXT
);
GO
INSERT INTO Table1 (ID, Column1) VALUES (1, 'Value1');
INSERT INTO Table2 (ID, Column1) VALUES (1, 'Value2');
GO

UPDATE Table1
SET Column1 = Table2.Column1
FROM Table1
INNER JOIN Table2
ON Table1.ID = Table2.ID;
GO

SELECT @@ROWCOUNT;

IF @@ROWCOUNT > 0
    PRINT 'Update successful';
ELSE
    PRINT 'Update failed';

SELECT * FROM Table1;
GO

-- ------------
/*
        When processing an export file via automation, ensure to architect your solution such 
        that it can deal with changing positions of a column. This statement is the reason for
        the dynamic SQL being used to capture the column positions from the staging table below. 
    */
CREATE TABLE Prod (
    ID INT PRIMARY KEY,
    Column1 TEXT,
	Column2 TEXT,
	Column3 TEXT
);

CREATE TABLE Temp (
    ID INT PRIMARY KEY,
    Column1 TEXT,
	Column2 TEXT
);

INSERT INTO Temp (ID, Column1, Column2) 
	VALUES (1, 'Value1', 'Value2');

INSERT INTO Temp (ID, Column1, Column2) 
	VALUES (2, 'Value3', 'Value4');

INSERT INTO Temp (ID, Column1, Column2) 
	VALUES (3, 'Value5', 'Value6');

INSERT INTO Prod (ID, Column1, Column2, Column3) 
	VALUES (1, 'Prod1', 'Prod2', 'Prod3');

SELECT * FROM Temp;
SELECT * FROM Prod;

UPDATE Prod
SET Column1 = t.Column1, Column2 = t.Column2 -- Column structure from Temp
FROM Prod p
INNER JOIN Temp t
ON p.ID = t.ID

INSERT INTO Prod (ID, Column1, Column2) -- Column structure from Temp
SELECT *
FROM Temp t
WHERE t.ID = 3;


SELECT c.name
FROM sys.columns c
WHERE c.object_id = OBJECT_ID('Temp')
