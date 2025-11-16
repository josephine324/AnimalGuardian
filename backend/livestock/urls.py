from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
# Register specific routes first, then the catch-all
router.register(r'types', views.LivestockTypeViewSet, basename='livestocktype')
router.register(r'breeds', views.BreedViewSet, basename='breed')
router.register(r'health-records', views.HealthRecordViewSet, basename='healthrecord')
router.register(r'vaccinations', views.VaccinationRecordViewSet, basename='vaccinationrecord')
# Register the main livestock route last (catch-all)
router.register(r'', views.LivestockViewSet, basename='livestock')

urlpatterns = [
    path('', include(router.urls)),
]
