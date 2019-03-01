#!/bin/bash

echo "#start application pwd and move into webapp dir"

pwd

cd /var/webapp_node/webapp

echo "PWD AND FILES"

pwd
sudo python3.6 manage.py makemigrations
sudo python3.6 manage.py migrate
sudo python3.6 manage.py runserver [::]:5000





