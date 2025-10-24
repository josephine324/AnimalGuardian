from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import Livestock, LivestockType, Breed, HealthRecord, VaccinationRecord
from .serializers import (
    LivestockSerializer, LivestockTypeSerializer, BreedSerializer,
    HealthRecordSerializer, VaccinationRecordSerializer
)

class LivestockViewSet(viewsets.ModelViewSet):
    """ViewSet for Livestock management."""
    queryset = Livestock.objects.all()
    serializer_class = LivestockSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Livestock.objects.filter(owner=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

class LivestockTypeViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for Livestock types."""
    queryset = LivestockType.objects.all()
    serializer_class = LivestockTypeSerializer

class BreedViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for Breeds."""
    queryset = Breed.objects.all()
    serializer_class = BreedSerializer

class HealthRecordViewSet(viewsets.ModelViewSet):
    """ViewSet for Health records."""
    queryset = HealthRecord.objects.all()
    serializer_class = HealthRecordSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        livestock_id = self.kwargs.get('livestock_pk')
        if livestock_id:
            return HealthRecord.objects.filter(livestock_id=livestock_id)
        return HealthRecord.objects.none()

class VaccinationRecordViewSet(viewsets.ModelViewSet):
    """ViewSet for Vaccination records."""
    queryset = VaccinationRecord.objects.all()
    serializer_class = VaccinationRecordSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        livestock_id = self.kwargs.get('livestock_pk')
        if livestock_id:
            return VaccinationRecord.objects.filter(livestock_id=livestock_id)
        return VaccinationRecord.objects.none()
