DROP TABLE Temp;
DROP TABLE Prod;

CREATE TABLE Prod (
    ID INT PRIMARY KEY,
    Column1 TEXT,
	Column2 TEXT
);

CREATE TABLE Temp (
    ID INT PRIMARY KEY,
    Column1 TEXT,
	Column2 TEXT, 
	Column3 TEXT
);

INSERT INTO Temp (ID, Column1, Column2, Column3) 
	VALUES (1, 'Value1', 'Value2', 'Value3');

INSERT INTO Temp (ID, Column1, Column2, Column3) 
	VALUES (2, 'Value4', 'Value5', 'Value6');

INSERT INTO Temp (ID, Column1, Column2, Column3) 
	VALUES (3, 'Value7', 'Value8', 'Value9');

INSERT INTO Prod (ID, Column1, Column2) 
	VALUES (1, 'Prod1', 'Prod2');

SELECT * FROM Temp;
SELECT * FROM Prod;

MERGE Prod AS Target
USING Temp	AS Source
ON Source.ID = Target.ID
    
-- For Updates
WHEN MATCHED THEN UPDATE SET
    Target.Column1	= Source.Column1,
    Target.Column2	= Source.Column2;

SELECT @@ROWCOUNT;

-- We have multiple MERGE declarations to observe individual DML effect
MERGE Prod AS Target
USING Temp	AS Source
ON Source.ID = Target.ID

-- For Inserts
WHEN NOT MATCHED BY Target THEN
    INSERT (ID, Column1, Column2) 
    VALUES (Source.ID, Source.Column1, Source.Column2);

SELECT @@ROWCOUNT;

SELECT * FROM Temp;
SELECT * FROM Prod;

DROP TABLE Temp;
-- Assuming temp schema changed at runtime
CREATE TABLE Temp (
    ID INT PRIMARY KEY,
    Column1 TEXT,
	Column3 TEXT, 
	Column2 TEXT
);

INSERT INTO Temp (ID, Column1, Column3, Column2) 
	VALUES (4, 'Value10', 'Value11', 'Value12');

SELECT * FROM Temp;
SELECT * FROM Prod;

MERGE Prod AS Target
USING Temp	AS Source
ON Source.ID = Target.ID

-- For Inserts
WHEN NOT MATCHED BY Target THEN
    INSERT (ID, Column1, Column2) 
    VALUES (Source.ID, Source.Column1, Source.Column2);

SELECT @@ROWCOUNT;

SELECT * FROM Temp;
SELECT * FROM Prod;



-- -- Positional change in upsert statement
-- MERGE Prod AS Target
-- USING Temp	AS Source
-- ON Source.ID = Target.ID
    
-- -- For Updates
-- WHEN MATCHED THEN UPDATE SET
--     Target.Column2	= Source.Column2,
--     Target.Column1	= Source.Column1;

-- SELECT * FROM Temp;
-- SELECT * FROM Prod;

-- MERGE Prod AS Target
-- USING Temp	AS Source
-- ON Source.ID = Target.ID

-- -- For Inserts
-- WHEN NOT MATCHED BY Target THEN
--     INSERT (ID, Column2, Column1) 
--     VALUES (Source.ID, Source.Column2, Source.Column1);

-- SELECT * FROM Temp;
-- SELECT * FROM Prod;