-- Create the container database if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'testdb')
BEGIN
  CREATE DATABASE testdb;
END
GO

-- Use the database
USE testdb;
GO

-- Create the mock_data table if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'mock_data')
BEGIN
  CREATE TABLE [dbo].[mock_data] (
    id INT PRIMARY KEY,
    first_name VARCHAR(100) NULL,
    last_name VARCHAR(100) NULL,
    email VARCHAR(100) NULL,
    gender VARCHAR(20) NULL,
    ip_address VARCHAR(100) NULL,
    updated_at DATE NULL
  );
END
GO
