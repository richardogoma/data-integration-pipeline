-- Execute this statement to create the production table
USE DataCleaningProjects
GO

CREATE TABLE [usr].[mock_data] (
    id INT PRIMARY KEY,
    first_name VARCHAR(100) NULL,
    last_name VARCHAR(100) NULL,
    email VARCHAR(100) NULL,
    gender VARCHAR(20) NULL,
    ip_address VARCHAR(100) NULL,
    updated_at DATE NULL
);
GO