from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'reports', views.CaseReportViewSet)
router.register(r'diseases', views.DiseaseViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
