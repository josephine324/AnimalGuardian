from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone
from accounts.models import User
from .models import CaseReport, Disease
from .serializers import CaseReportSerializer, DiseaseSerializer

class CaseReportViewSet(viewsets.ModelViewSet):
    """ViewSet for Case reports."""
    queryset = CaseReport.objects.all()
    serializer_class = CaseReportSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        user_type = user.user_type
        
        # Farmers: Only see their own cases
        if user_type == 'farmer':
            return CaseReport.objects.filter(reporter=user)
        
        # Local Vets: See cases assigned to them
        elif user_type == 'local_vet':
            return CaseReport.objects.filter(assigned_veterinarian=user)
        
        # Sector Vets and Admins: See all cases
        elif user_type in ['sector_vet', 'admin'] or user.is_staff or user.is_superuser:
            return CaseReport.objects.all()
        
        # Field Officers: See cases assigned to them (if any)
        elif user_type == 'field_officer':
            return CaseReport.objects.filter(assigned_veterinarian=user)
        
        # Default: Only own cases
        return CaseReport.objects.filter(reporter=user)
    
    @action(detail=True, methods=['post'])
    def assign(self, request, pk=None):
        """Assign a case to a local veterinarian (sector vet/admin only)."""
        case = self.get_object()
        assigner = request.user
        
        # Check if assigner is sector vet or admin
        if not (assigner.is_staff or assigner.is_superuser or assigner.user_type in ['admin', 'sector_vet']):
            return Response({
                'error': 'You do not have permission to assign cases. Only sector veterinarians and administrators can assign cases.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        veterinarian_id = request.data.get('veterinarian_id')
        if not veterinarian_id:
            return Response({
                'error': 'veterinarian_id is required.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            veterinarian = User.objects.get(id=veterinarian_id, user_type='local_vet')
        except User.DoesNotExist:
            return Response({
                'error': 'Local veterinarian not found.'
            }, status=status.HTTP_404_NOT_FOUND)
        
        case.assigned_veterinarian = veterinarian
        case.assigned_at = timezone.now()
        case.assigned_by = assigner
        case.status = 'under_review'
        case.save()
        
        return Response({
            'message': f'Case assigned to {veterinarian.get_full_name() or veterinarian.username}',
            'case': CaseReportSerializer(case).data
        }, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['post'])
    def unassign(self, request, pk=None):
        """Unassign a case from a veterinarian (sector vet/admin only)."""
        case = self.get_object()
        assigner = request.user
        
        # Check if assigner is sector vet or admin
        if not (assigner.is_staff or assigner.is_superuser or assigner.user_type in ['admin', 'sector_vet']):
            return Response({
                'error': 'You do not have permission to unassign cases.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        case.assigned_veterinarian = None
        case.assigned_at = None
        case.assigned_by = None
        case.status = 'pending'
        case.save()
        
        return Response({
            'message': 'Case unassigned successfully.',
            'case': CaseReportSerializer(case).data
        }, status=status.HTTP_200_OK)

class DiseaseViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for Diseases."""
    queryset = Disease.objects.all()
    serializer_class = DiseaseSerializer
