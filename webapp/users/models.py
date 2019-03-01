from django.db import models
from django.contrib.auth.models import AbstractUser, UserManager
from django import forms
from datetime import datetime
from django.shortcuts import render, redirect

# Create your models here.

#published_date = models.DateTimeField(default=datetime.now)
#fileurl = models.FileField(upload_to='experiments/')
class CustomUserManager(UserManager):
      pass

class CustomUser(AbstractUser):
      objects = CustomUserManager()

class Experiment(models.Model):
	experiment_id = models.AutoField(primary_key=True)
	name = models.CharField(max_length=255)	
	cell_line = models.CharField(max_length=255)	
	treatment = models.CharField(max_length=255)	
	user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)	
	fileurl = models.FileField(max_length=255, upload_to='proteins/')	
	status = models.CharField(max_length=255, default='New')	
	published_date = models.DateTimeField(default=datetime.now)

class ExperimentName(models.Model):
	exp_id = models.AutoField(primary_key=True)
	experiment_name = models.CharField(max_length=255)	
	experiment_value = models.CharField(max_length=255)

class ExperimentDetails(models.Model):
	tbl_id = models.AutoField(primary_key=True)
	frequency = models.PositiveIntegerField()
	ID = models.CharField(max_length=255)	
	accession = models.CharField(max_length=255)	
	experiment = models.PositiveIntegerField()	
	direct_of_change = models.CharField(max_length=255)	
	logFC = models.DecimalField(decimal_places=24,max_digits=25)	
	Pvalue = models.DecimalField(decimal_places=24,max_digits=25, null=True)
	updated_date = models.DateTimeField(default=datetime.now)

