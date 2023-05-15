# Data Integration Pipeline

## Overview
At a high level, this program represents a data integration pipeline. It takes data from flat files and integrates it into a production table on an SQL Server database. 

<img src="https://github.com/richardogoma/data-integration-pipeline/assets/108296666/22445f16-b39e-4e72-a61a-19eb76764ad1" alt="Digraph: Data Integration Pipeline Data and Control Flow" style="display: block; margin-left: auto; margin-right: auto;" width="500" height="500">

Here is a high-level summary of what the program does:

1. **Setup**: The program performs initial setup tasks such as creating and running the Docker container for the service, reading the configuration file, and unpacking configuration parameters.

2. **Data Staging**: The program prepares the data for integration by converting its format from CSV to TSV, creating a dynamic temporary table schema, and bulk copying the raw data into the temporary table.

3. **Data Integration**: The program integrates the staged data into the production table. It checks if the production table exists, and if it does, it proceeds to transform the staged data and incrementally load it into the production table.

4. **Logging**: The program logs the output of the data integration process and records the program's runtime. It writes the data integration output to a log and also logs the program's runtime.

5. **Error Handling**: The program includes error handling mechanisms. If any errors occur during the execution, they are caught, and the error message is printed to the console.

In summary, this program automates the process of integrating data from flat files into a production table on an SQL Server database, handling data staging, transformation, and logging, while also providing error handling capabilities.

## Use Case
The program can be used to extend the functionality of a program developed to programmatically extract data from an API endpoint as flat files, and to integrate that data into a central repository to support the data management, analytics and BI systems.

## Running the program
* The program's configurations is defined in defined the `.env` file in the programs root dir:
    ```env
    SA_PASSWORD=#Type_your_strong_password_here
    DATABASE=testdb
    SCHEMA=dbo
    TABLE=mock_data
    DB_USER=sa
    DATASET=mock_data.csv
    SQL_SERVER_IP=0.0.0.0,1433
    ```
* The input to the program is data in `data\raw` directory
* The Docker service contract is defined in `docker-compose.yml`

    ```bash
    # Run the data integration service
    chmod +x run.sh && ./run.sh
    ```
* See tail of `run.sh` for useful `sql` commands to test the data load status
        
    > If the program is invoked in another program, considering the use case, the program **should** be architected to egress the input data to `data\raw` directory, and the configuration parameters in `.env` can be programmatically updated using placeholders, especially the `DATASET` and `TABLE` keys. 
    See `src\utils\fxIntegrateStagedData.ps1` and `src\data\transform-data-template.sql` for a use case on programmatically updating text files using placeholders.

## Constraints
* The source data could either be in `.csv` or `.tsv` file format. These are commonly used file formats for data transport, and they're non-binary files.
* The primary key has to be _the first field in the source data._ This is a best practice.

    > The primary key should be the first field in your table design. While most databases allow you to define the primary key on any field in your table, the common convention and what the next developer will expect, is the primary key field coming first.

* The primary key field should _be of numeric datatype._ While it is true that there could be some irregularity in the source data, like there could be some strings in the primary key column, it is best practise to use a numeric field as primary key. Preliminary clean-up has been built into the program to expunge rows that are non-numeric in the primary key field; the primary key field is `id`. 

    > Uniquely tagging a record can be done with a number (long integer). Text fields require more bytes than numeric fields, so using a number saves considerable space. Please refer to this article on [Primary Key Tips and Techniques](https://www.fmsinc.com/free/newtips/PrimaryKey.asp)

* The production tables have to be created before executing the program with the correct datatypes for each field. 

* The source data must have an `updated_at` field. This is particularly useful for incrementally loading the data to the production table.



