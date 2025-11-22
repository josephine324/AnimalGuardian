from rest_framework import viewsets, status
from rest_framework.permissions import IsAuthenticated, AllowAny
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
        
        # Optimize queries with select_related to prevent N+1 queries
        base_queryset = Livestock.objects.select_related(
            'owner',           # User who owns the livestock
            'livestock_type',  # Livestock type
            'breed'            # Breed (if exists)
        )
        
        # Farmers: Only see their own livestock
        if user_type == 'farmer':
            return base_queryset.filter(owner=user)
        
        # Local Vets: See livestock of farmers whose cases are assigned to them
        elif user_type == 'local_vet':
            from cases.models import CaseReport
            # Get all cases assigned to this vet
            assigned_cases = CaseReport.objects.filter(assigned_veterinarian=user)
            # Get livestock from those cases
            livestock_ids = assigned_cases.values_list('livestock_id', flat=True).distinct()
            # Also get livestock owned by farmers who have cases assigned to this vet
            farmer_ids = assigned_cases.values_list('reporter_id', flat=True).distinct()
            return base_queryset.filter(
                models.Q(id__in=livestock_ids) | models.Q(owner_id__in=farmer_ids)
            ).distinct()
        
        # Sector Vets and Admins: See all livestock
        elif user_type in ['sector_vet', 'admin'] or user.is_staff or user.is_superuser:
            return base_queryset.all()
        
        # Default: Only own livestock
        return base_queryset.filter(owner=user)
    
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
    """ViewSet for Livestock types.
    Public read access - livestock types are reference data needed by all users.
    """
    queryset = LivestockType.objects.all()
    serializer_class = LivestockTypeSerializer
    permission_classes = [AllowAny]  # Public read access for reference data

class BreedViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for Breeds.
    Public read access - breeds are reference data needed by all users.
    """
    serializer_class = BreedSerializer
    permission_classes = [AllowAny]  # Public read access for reference data
    
    def get_queryset(self):
        """Filter breeds by livestock_type if provided in query parameters."""
        queryset = Breed.objects.select_related('livestock_type').all()
        
        # Filter by livestock_type if provided
        livestock_type_id = self.request.query_params.get('livestock_type', None)
        if livestock_type_id:
            try:
                queryset = queryset.filter(livestock_type_id=int(livestock_type_id))
            except (ValueError, TypeError):
                # Invalid livestock_type_id, return all breeds
                pass
        
        return queryset.order_by('livestock_type__name', 'name')

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
