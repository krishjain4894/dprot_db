#!/bin/sh
python manage.py makemigrations
python manage.py migrate
python manage.py runserver [::]:5000