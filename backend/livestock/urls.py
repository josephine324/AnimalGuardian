from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'', views.LivestockViewSet)
router.register(r'types', views.LivestockTypeViewSet)
router.register(r'breeds', views.BreedViewSet)
router.register(r'health-records', views.HealthRecordViewSet)
router.register(r'vaccinations', views.VaccinationRecordViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
