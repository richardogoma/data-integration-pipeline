#!/bin/bash

# Create environment variable file for docker-compose environment params
env_var="SA_PASSWORD=P@s5wOrd
DATABASE=testdb
SCHEMA=dbo
TABLE=mock_data
DB_USER=sa
DATASET=mock_data.csv
SQL_SERVER_IP=0.0.0.0,1433"
echo "$env_var" > .env
echo "Environment variables file created in root directory ...."

# Verify that the data/raw dir isn't empty
if [[ $(find data/raw -mindepth 1 -print -quit) ]]; then
    echo "data/raw directory is not empty."
else
    echo "data/raw directory is empty."
    exit 1
fi

# Build and run the sql-server-db service
docker-compose up -d --remove-orphans sql-server-db

sleep 30

# Print to console sql-server-db-IP-ADDRESS
ip_address=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dc_sql-server-db)

echo "sql-server-db container ip: $ip_address"

export SQL_SERVER_IP=$ip_address

# Print to console sql-server-db-PORT
# port=$(docker inspect -f '{{range $p, $conf := .NetworkSettings.Ports}}{{(index $conf 0).HostPort}} -> {{$p}}{{end}}' dc_sql-server-db)
port=$(docker inspect -f '{{range $p, $conf := .NetworkSettings.Ports}}{{(index $conf 0).HostPort}}{{end}}' dc_sql-server-db)

echo "sql-server-db container host port: $port"

# Build and run the data-integrator service
docker-compose up -d --remove-orphans data-integrator

sleep 30

# -----------------------------------
# Set some environment variables defined in the .env file
eval $(cat .env | grep SA_PASSWORD)
eval $(cat .env | grep DB_USER)

# Invoke sqlcmd in container db
echo "Invoking the sqlcmd terminal in sql-server-db service ...."
echo "See .db/data-load-query.sql for sql command examples to run in terminal ...."
echo "Press Ctrl + C to terminate the process."
docker exec -it dc_sql-server-db /opt/mssql-tools/bin/sqlcmd -S $ip_address,$port -U $DB_USER -P $SA_PASSWORD

# exit