from django.shortcuts import render
from django import forms
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from users.models import Experiment

# pages/views.py
from django.views.generic import TemplateView


class HomePageView(TemplateView):
    template_name = 'home.html'# Create your views here.

def home(request):
    experiments = Experiment.objects.all()
    return render(request, 'dashboard.html',{ 'experiments': experiments })
	
#def delete(request):
#  if request.method == 'POST':
#    file = request.POST['experiment']
#    CustomExperiment.objects.filter(fileurl=file).delete()
#   experiments = CustomExperiment.objects.all()
#    return render(request, 'home.html',{ 'experiments': experiments })
	
#def analysis(request):
#  if request.method == 'POST':
#    file = request.POST['experiment']
#   experiment1 = CustomExperiment.objects.get(fileurl=file)
#    return render(request, 'analysis.html',{ 'experiment1': experiment1 })    

