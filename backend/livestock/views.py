from rest_framework import viewsets, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db import models, IntegrityError
from django.core.exceptions import ValidationError as DjangoValidationError
from .models import Livestock, LivestockType, Breed, HealthRecord, VaccinationRecord
from .serializers import (
    LivestockSerializer, LivestockTypeSerializer, BreedSerializer,
    HealthRecordSerializer, VaccinationRecordSerializer
)
import logging

logger = logging.getLogger(__name__)

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
    
    def create(self, request, *args, **kwargs):
        """Handle livestock creation with better error handling."""
        user = request.user
        # Only farmers can create livestock
        if user.user_type != 'farmer':
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("Only farmers can create livestock records.")
        
        # Log the incoming request data for debugging
        logger.info(f"Creating livestock for user {user.id}: {request.data}")
        
        serializer = self.get_serializer(data=request.data)
        try:
            serializer.is_valid(raise_exception=True)
            logger.info(f"Serializer is valid. Saving livestock...")
            serializer.save(owner=user)
            headers = self.get_success_headers(serializer.data)
            return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)
        except IntegrityError as e:
            logger.error(f"Integrity error creating livestock: {e}", exc_info=True)
            error_message = "A livestock record with this information already exists."
            if 'tag_number' in str(e):
                error_message = "A livestock with this tag number already exists. Please use a different tag number or leave it blank."
            return Response(
                {'error': error_message, 'detail': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
        except DjangoValidationError as e:
            logger.error(f"Validation error creating livestock: {e}", exc_info=True)
            error_detail = str(e)
            if hasattr(e, 'message_dict'):
                error_detail = e.message_dict
            return Response(
                {'error': 'Validation error', 'detail': error_detail},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            import traceback
            error_traceback = traceback.format_exc()
            logger.error(f"Unexpected error creating livestock: {e}\n{error_traceback}")
            return Response(
                {
                    'error': 'An error occurred while creating the livestock record. Please try again.',
                    'detail': str(e),
                    'type': type(e).__name__
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

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
