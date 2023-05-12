/*
This script checks if the production/integration table exists, transforms and integrates data into a target table from the staging table, 
and then drops the staging table.
*/
IF OBJECT_ID(N'[$(Schema)].[$(TableName)]') IS NOT NULL
BEGIN;
    -- ================Staging data transformation
    -- 
    DELETE FROM [$(Schema)].[temp_$(TableName)]
    WHERE $(PrimaryKey) LIKE '%[^0-9]%';
    -- There is no primary key constraint in the staging table, this is a representation 
    -- of the integration table design
    /*
        The staging table is a temporary table that holds all of the data that will be used
        to make changes to the target table, including both updates and inserts. 
    */

    -- The purpose of these queries is to optimize the integration of data from the staging area
    SET DATEFORMAT mdy; 
    ALTER TABLE [$(Schema)].[temp_$(TableName)] ALTER COLUMN $(PrimaryKey) INT;
    ALTER TABLE [$(Schema)].[temp_$(TableName)] ALTER COLUMN updated_at DATE;
    CREATE CLUSTERED INDEX $(PrimaryKey)_ASC ON [$(Schema)].[temp_$(TableName)] ($(PrimaryKey));

    -- ================Integration phase
    /*
        "When processing an export file via automation, ensure to architect your solution such 
        that it can deal with changing positions of a column"- The MERGE constructs are ideal
        for dealing with changing column positions in the landing zone. 
    */
    -- Update the integration table incrementally
    MERGE [$(Schema)].[$(TableName)] AS Target
    USING [$(Schema)].[temp_$(TableName)]	AS Source
    ON 
    (
        Source.$(PrimaryKey) = Target.$(PrimaryKey) AND 
        Source.updated_at != Target.updated_at
    )
        
    -- For Updates
    WHEN MATCHED THEN UPDATE SET
        {0}

    -- return the affected rows from DML UPDATE Statement
    SELECT @@ROWCOUNT [UpdatedRows];

    MERGE [$(Schema)].[$(TableName)] AS Target
    USING [$(Schema)].[temp_$(TableName)]	AS Source
    ON Source.$(PrimaryKey) = Target.$(PrimaryKey)

    -- For Inserts
    WHEN NOT MATCHED BY Target THEN
        INSERT ({1}) 
        VALUES ({2});

    -- return the affected rows from DML INSERT Statement
    SELECT @@ROWCOUNT [InsertedRows];

    -- ==================Clean-up phase
    -- Drop the staging table
    DROP TABLE [$(Schema)].[temp_$(TableName)];
END;