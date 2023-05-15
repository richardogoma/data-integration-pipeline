#!/bin/bash

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

# Set the environment variables defined in the .env file
eval $(cat .env | grep SA_PASSWORD)
eval $(cat .env | grep DB_USER)

# Invoke sqlcmd in container db
echo "Run sql commands in terminal ...."
docker exec -it dc_sql-server-db /opt/mssql-tools/bin/sqlcmd -S $ip_address,$port -U $DB_USER -P $SA_PASSWORD

timeout 30 
# --------------------------------
# Run these to confirm data loaded to database table
# select name from sys.databases;
# go

# use testdb;

# select name from sys.tables;
# go

# select top 5 first_name from mock_data;
# go

# exit
