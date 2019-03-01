from django.shortcuts import render, redirect

# Create your views here.
# users/views.py
from django.urls import reverse_lazy
from django.views import generic

from .forms import CustomUserCreationForm
from .forms import CustomExperimentCreationForm
from users.models import Experiment
from users.models import ExperimentName
from users.models import ExperimentDetails

import subprocess
import logging
import os
import shutil
import csv
import datetime
import pandas as pd

# Standard instance of a logger with __name__
stdlogger = logging.getLogger(__name__)


def processFile():
    stdlogger.debug("Processing the uploaded file")
    data_main = pd.read_csv('/home/ch207814/proteomicsproject/tables/temp_all_data.csv')
    for x in range(0, len(data_main)):
      data = data_main[x:x+1].copy()

      y = 2
      for y in range(y, len(data.columns), 2):
          df3 = data.iloc[[0], [0, 1, y, y+1]]
          key = df3.columns[2]
          keyParams = key.split("|")
          firstParamVal = keyParams[0]
          thirdParamVal = keyParams[2]
          try:
            obj = ExperimentName.objects.get(experiment_name=firstParamVal, experiment_value = thirdParamVal)
          except ExperimentName.DoesNotExist:
            obj = ExperimentName(experiment_name=firstParamVal, experiment_value = thirdParamVal)
            obj.save()
          experiment_id = obj.exp_id
          explist = df3.values[0].tolist()
          exp_detail = ExperimentDetails(frequency=0, ID=explist[1], accession = explist[0], experiment=experiment_id, direct_of_change='down', logFC=explist[2], Pvalue=explist[3])
          exp_detail.save()

    os.remove("/home/ch207814/proteomicsproject/tables/temp_all_data.csv")
    stdlogger.debug("File Removed!")
    source = '/home/ch207814/proteomicsproject/proteins/'
    dest1 = '/home/ch207814/proteomicsproject/experiments/'
    files = os.listdir(source)
    for f in files:
          # shutil.move(source+f, dest1)
          shutil.move(os.path.join(source, f), os.path.join(dest1, f))
    stdlogger.debug("Files Moved To Experiments!")
    stdlogger.debug("Processing complete")

class SignUp(generic.CreateView):
    stdlogger.debug("Entered SignUp Class")
    form_class = CustomUserCreationForm
    success_url = reverse_lazy('login')
    template_name = 'signup.html'
  

class LogOut(generic.CreateView):
    stdlogger.debug("Entering Logout Class")
    template_name = 'home.html'

def dashboard(request):
    stdlogger.debug("Entered Dashboard Method")
    if request.method == 'POST':
        stdlogger.debug("Entered Dashboard Post Request")
        form = CustomExperimentCreationForm(request.POST, request.FILES)
        if form.is_valid():
            stdlogger.debug("Form is Valid")
            form.save()
            return redirect('home')
        else:
            stdlogger.error("Form Data Invalid")
    else:
        stdlogger.debug("Entered Dashboard Get Request")
        experiments2 = Experiment.objects.all()
        # experiments2 = experiments2.filter(fileurl__icontains="proteins").update(fileurl='experiments/')
        stdlogger.debug("Fetched Experiments Records From Database")
        return render(request, 'dashboard.html',{ 'experiments': experiments2 })


def upload(request):
    if request.method =='POST':
       stdlogger.debug("Entered Upload Post Request.. Calling R Script")
       #print('in upload post')
       form = CustomExperimentCreationForm(request, request.POST, request.FILES)
       stdlogger.debug(form)
       if form.is_valid():
          stdlogger.debug("Entered Upload Post Request")
          obj = form.save(commit=False)
          obj.user = request.user
          obj.save()
          stdlogger.debug("Form Saved Sucessfully")
          subprocess.call("Rscript /home/ch207814/proteomicsproject/20181127_jwb_pd22_wp_combine.r", shell=True )
          stdlogger.debug("RScript Executed Successfully")
          processFile()
          stdlogger.debug("File Processed Successfully")
          # experiments = CustomExperiment.objects.all()
          return redirect('dashboard')
       else:
          stdlogger.error("Submit Request Failed. Redirected to Dashboard Page")
          return redirect('dashboard')
    else:
        stdlogger.debug("Entered Get Upload Form Request")
        form = CustomExperimentCreationForm(request)
        stdlogger.debug(form)
        return render(request, 'upload-experiment.html',{'form':form})

def delete(request):
    stdlogger.debug("Entered Delete Method")
    if request.method == 'POST':
       stdlogger.debug("In Delete Post Request")
       print(request)
       if request.GET.get('experiment', None) is None:
          stdlogger.error('Error! Experiment Not Selected')
          return redirect('dashboard')
       else:
          id = request.GET['experiment']
          Experiment.objects.filter(experiment_id=id).delete()
          experiments = Experiment.objects.all()
          return redirect('dashboard')
  
def analysis(request):
  stdlogger.debug("Entered Analysis Method")
  if request.method == 'POST':
    stdlogger.debug("Entered Analysis Post Request")
    id = request.GET['experiment']
    experiment1 = Experiment.objects.get(experiment_id=id)
    return render(request, 'analysis.html',{ 'experiment1': experiment1 })
  
def download(request):
  stdlogger.debug("Entered Download Method")
  if request.method == 'POST':
    stdlogger.debug("Entered Download Post Request")
    file = request.POST['experiment']
    experiment1 = Experiment.objects.get(fileurl=file)
    return render(request, 'dashboard.html')
