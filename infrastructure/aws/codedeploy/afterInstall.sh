#!/bin/bash



# update the permission and ownership of WAR file in the tomcat webapps directory

echo " doing after install"

echo "Installing zip/unzip" 

sudo yum install zip unzip -y

sudo su -

sudo systemctl start postgresql

psql -U postgres -c "CREATE USER proteomicsuser WITH PASSWORD 'proteomicspassword';"

psql -U postgres -c "CREATE DATABASE proteomicsdb;"

psql -U postgres -c "ALTER ROLE proteomicsuser SET client_encoding TO 'utf8';"

psql -U postgres -c "ALTER ROLE proteomicsuser SET default_transaction_isolation TO 'read committed';"

psql -U postgres -c "ALTER ROLE proteomicsuser SET timezone TO 'EST';"

psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE proteomicsdb TO proteomicsuser;"

#sudo postgresql-setup initdb


#sudo systemctl status postgresql

cd /var

pwd

ls -lrt

echo "doing after install: remove webapp_node if already exist"

sudo rm -rf webapp_node

ls -lrt

echo " doing after install: make dir webapp_node"

sudo mkdir -p webapp_node

pwd

ls -lrt

echo "doing after install: move zip to webapp_node dir"

sudo mv csye6225-fall2018.zip webapp_node/

cd webapp_node/

echo "doing after install: go in webapp_node"

pwd

ls -lrt

echo "doing after install: unzip app"

sudo unzip csye6225-fall2018.zip

cd dprot_db/

ls -lrt

sudo unzip csye6225-fall.zip

echo " doing after install: remove zip from webapp_node folder"

sudo rm -rf csye6225-fall2018.zip

echo " doing after install: end"

pwd

ls -lrt

cd ..

sudo cp .env webapp_node/webapp

cd webapp_node/webapp

sudo chmod 666 .env

pwd

ls -lrt

cd ../..

pwd

ls -lrt
