from django.urls import path
from . import views

urlpatterns = [
    path('', views.weather_current, name='weather_current'),
]

