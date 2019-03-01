from django.shortcuts import render
from django import forms
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from users.models import Experiment

# pages/views.py
from django.views.generic import TemplateView


	
def delete(request):
    experiments = Experiment.objects.all()
    return render(request, 'home.html',{ 'experiments': experiments })
	
def analysis(request):
    experiments = Experiment.objects.all()
    return render(request, 'home.html',{ 'experiments': experiments })