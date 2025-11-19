from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from django.db import models
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
        user = self.request.user
        user_type = user.user_type
        
        # Farmers: Only see their own livestock
        if user_type == 'farmer':
            return Livestock.objects.filter(owner=user)
        
        # Local Vets: See livestock of farmers whose cases are assigned to them
        elif user_type == 'local_vet':
            from cases.models import CaseReport
            # Get all cases assigned to this vet
            assigned_cases = CaseReport.objects.filter(assigned_veterinarian=user)
            # Get livestock from those cases
            livestock_ids = assigned_cases.values_list('livestock_id', flat=True).distinct()
            # Also get livestock owned by farmers who have cases assigned to this vet
            farmer_ids = assigned_cases.values_list('reporter_id', flat=True).distinct()
            return Livestock.objects.filter(
                models.Q(id__in=livestock_ids) | models.Q(owner_id__in=farmer_ids)
            ).distinct()
        
        # Sector Vets and Admins: See all livestock
        elif user_type in ['sector_vet', 'admin'] or user.is_staff or user.is_superuser:
            return Livestock.objects.all()
        
        # Default: Only own livestock
        return Livestock.objects.filter(owner=user)
    
    def perform_create(self, serializer):
        user = self.request.user
        # Only farmers can create livestock
        if user.user_type != 'farmer':
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("Only farmers can create livestock records.")
        serializer.save(owner=user)

class LivestockTypeViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for Livestock types."""
    queryset = LivestockType.objects.all()
    serializer_class = LivestockTypeSerializer
    permission_classes = [IsAuthenticated]  # Require authentication

class BreedViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for Breeds."""
    queryset = Breed.objects.all()
    serializer_class = BreedSerializer
    permission_classes = [IsAuthenticated]  # Require authentication

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
