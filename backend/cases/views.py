from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone
from django.core.mail import send_mail
from django.conf import settings
from django.db import transaction
import threading
import logging
from accounts.models import User
from .models import CaseReport, Disease
from .serializers import CaseReportSerializer, DiseaseSerializer

logger = logging.getLogger(__name__)

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
    
    def perform_create(self, serializer):
        """Automatically set the reporter to the current user when creating a case."""
        serializer.save(reporter=self.request.user)
    
    def perform_update(self, serializer):
        """Handle case updates and send notifications on status change."""
        old_instance = self.get_object()
        old_status = old_instance.status
        
        # Save the updated instance
        instance = serializer.save()
        new_status = instance.status
        
        # If status changed, send notifications
        if old_status != new_status:
            self._send_status_change_notifications(instance, old_status, new_status)
    
    def _send_status_change_notifications(self, case, old_status, new_status):
        """Send notifications to farmer and vet when case status changes."""
        from notifications.models import Notification
        
        status_display = dict(CaseReport.STATUS_CHOICES).get(new_status, new_status)
        old_status_display = dict(CaseReport.STATUS_CHOICES).get(old_status, old_status)
        
        # Notify the farmer (reporter)
        if case.reporter:
            # In-app notification for farmer
            Notification.objects.create(
                recipient=case.reporter,
                channel='in_app',
                title='Case Status Updated',
                message=f'Your case {case.case_id} status has been updated from {old_status_display} to {status_display}.',
                related_case=case,
                status='sent',
                sent_at=timezone.now()
            )
            
            # Email notification to farmer
            def send_farmer_status_email():
                try:
                    if case.reporter.email:
                        subject = f'AnimalGuardian - Case {case.case_id} Status Updated'
                        message = f'''
Hello {case.reporter.get_full_name() or case.reporter.username},

Your case report status has been updated.

Case ID: {case.case_id}
Previous Status: {old_status_display}
New Status: {status_display}
Urgency: {case.get_urgency_display()}

Please check the AnimalGuardian mobile app for more details.

Best regards,
AnimalGuardian Team
'''
                        send_mail(
                            subject=subject,
                            message=message,
                            from_email=settings.DEFAULT_FROM_EMAIL,
                            recipient_list=[case.reporter.email],
                            fail_silently=True,
                        )
                        logger.info(f'Status change email sent to farmer {case.reporter.email} for case {case.case_id}')
                except Exception as e:
                    logger.error(f'Error sending status email to farmer: {str(e)}', exc_info=True)
            
            if case.reporter.email:
                email_thread = threading.Thread(target=send_farmer_status_email)
                email_thread.daemon = True
                email_thread.start()
        
        # Notify the assigned veterinarian (if any)
        if case.assigned_veterinarian:
            # In-app notification for vet
            Notification.objects.create(
                recipient=case.assigned_veterinarian,
                channel='in_app',
                title='Case Status Updated',
                message=f'Case {case.case_id} status has been updated to {status_display}.',
                related_case=case,
                status='sent',
                sent_at=timezone.now()
            )
            
            # Email notification to vet
            def send_vet_status_email():
                try:
                    if case.assigned_veterinarian.email:
                        subject = f'AnimalGuardian - Case {case.case_id} Status Updated'
                        message = f'''
Hello {case.assigned_veterinarian.get_full_name() or case.assigned_veterinarian.username},

The status of case {case.case_id} has been updated.

Case ID: {case.case_id}
Previous Status: {old_status_display}
New Status: {status_display}
Reporter: {case.reporter.get_full_name() or case.reporter.username}

Please check the AnimalGuardian mobile app for more details.

Best regards,
AnimalGuardian Team
'''
                        send_mail(
                            subject=subject,
                            message=message,
                            from_email=settings.DEFAULT_FROM_EMAIL,
                            recipient_list=[case.assigned_veterinarian.email],
                            fail_silently=True,
                        )
                        logger.info(f'Status change email sent to vet {case.assigned_veterinarian.email} for case {case.case_id}')
                except Exception as e:
                    logger.error(f'Error sending status email to vet: {str(e)}', exc_info=True)
            
            if case.assigned_veterinarian.email:
                email_thread = threading.Thread(target=send_vet_status_email)
                email_thread.daemon = True
                email_thread.start()
    
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
        
        # Check if veterinarian is available (online)
        from accounts.models import VeterinarianProfile
        try:
            vet_profile = veterinarian.vet_profile
            if not vet_profile.is_available:
                return Response({
                    'error': 'This veterinarian is currently offline and cannot receive new case assignments.'
                }, status=status.HTTP_400_BAD_REQUEST)
        except VeterinarianProfile.DoesNotExist:
            return Response({
                'error': 'Veterinarian profile not found.'
            }, status=status.HTTP_404_NOT_FOUND)
        
        case.assigned_veterinarian = veterinarian
        case.assigned_at = timezone.now()
        case.assigned_by = assigner
        case.status = 'under_review'
        case.save()
        
        # Send notifications to assigned veterinarian
        from notifications.models import Notification
        
        # In-app notification
        Notification.objects.create(
            recipient=veterinarian,
            channel='in_app',
            title='New Case Assigned',
            message=f'You have been assigned a new case: {case.case_id}. Urgency: {case.get_urgency_display()}',
            related_case=case,
            status='sent',
            sent_at=timezone.now()
        )
        
        # Email notification to veterinarian
        def send_assignment_email():
            try:
                if veterinarian.email:
                    subject = f'AnimalGuardian - New Case Assigned: {case.case_id}'
                    message = f'''
Hello {veterinarian.get_full_name() or veterinarian.username},

You have been assigned a new case on AnimalGuardian.

Case ID: {case.case_id}
Urgency: {case.get_urgency_display()}
Status: {case.get_status_display()}
Reported by: {case.reporter.get_full_name() or case.reporter.username}
Location: {case.location_notes or 'Not specified'}

Please review the case details in the AnimalGuardian mobile app and take appropriate action.

Best regards,
AnimalGuardian Team
'''
                    send_mail(
                        subject=subject,
                        message=message,
                        from_email=settings.DEFAULT_FROM_EMAIL,
                        recipient_list=[veterinarian.email],
                        fail_silently=True,
                    )
                    logger.info(f'Assignment email sent to {veterinarian.email} for case {case.case_id}')
            except Exception as e:
                logger.error(f'Error sending assignment email: {str(e)}', exc_info=True)
        
        # Send email in background thread
        if veterinarian.email:
            email_thread = threading.Thread(target=send_assignment_email)
            email_thread.daemon = True
            email_thread.start()
        
        return Response({
            'message': f'Case assigned to {veterinarian.get_full_name() or veterinarian.username}',
            'case': CaseReportSerializer(case).data
        }, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['get'])
    def available_vets_by_location(self, request):
        """Get available local veterinarians by location (sector vet/admin only)."""
        assigner = request.user
        
        # Check if assigner is sector vet or admin
        if not (assigner.is_staff or assigner.is_superuser or assigner.user_type in ['admin', 'sector_vet']):
            return Response({
                'error': 'You do not have permission to view available veterinarians.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Get location filters from query params
        sector = request.query_params.get('sector')
        district = request.query_params.get('district')
        
        from accounts.models import VeterinarianProfile
        queryset = VeterinarianProfile.objects.filter(is_available=True)
        
        # Filter by location if provided
        if sector:
            queryset = queryset.filter(user__sector=sector)
        if district:
            queryset = queryset.filter(user__district=district)
        
        # Get only local vets
        available_vets = []
        for profile in queryset:
            if profile.user.user_type == 'local_vet':
                available_vets.append({
                    'id': profile.user.id,
                    'name': profile.user.get_full_name() or profile.user.username,
                    'phone': profile.user.phone_number,
                    'sector': profile.user.sector,
                    'district': profile.user.district,
                    'specialization': profile.specialization,
                    'license_number': profile.license_number,
                })
        
        return Response({
            'available_veterinarians': available_vets,
            'count': len(available_vets)
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
