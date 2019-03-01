# users/urls.py
from django.urls import path
from django.conf.urls import url
from . import views

urlpatterns = [
    path('signup/', views.SignUp.as_view(), name='signup'),
	#path('login/', views.LogIn.as_view(), name='login'),
	path('dashboard', views.dashboard, name='dashboard'),
	path('dashboard/experiment/upload', views.upload, name='upload'),
    path('dashboard/experiment/delete', views.delete, name='delete'),
	path('dashboard/experiment/analysis', views.analysis, name='analysis'),
	path('dashboard/experiment/download', views.download, name='download')

]
