# pages/urls.py
from django.urls import path
from django.conf.urls import url

from . import views

urlpatterns = [
    path('', views.HomePageView.as_view(), name='home'),
]
