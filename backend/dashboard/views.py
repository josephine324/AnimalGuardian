from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework import status
from django.db import connection
from django.utils import timezone
from accounts.models import User
from cases.models import CaseReport
from livestock.models import Livestock
from notifications.models import Notification

@api_view(['GET'])
@permission_classes([AllowAny])
def health_check(request):
    """Health check endpoint that pings the database to keep it alive"""
    try:
        # Simple database query to keep connection alive
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
        
        return Response({
            'status': 'healthy',
            'database': 'connected',
            'timestamp': timezone.now().isoformat(),
        }, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({
            'status': 'unhealthy',
            'database': 'disconnected',
            'error': str(e),
            'timestamp': timezone.now().isoformat(),
        }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def stats(request):
    """Dashboard statistics endpoint"""
    user = request.user
    user_type = user.user_type
    
    # Only sector vets and admins can see all stats
    if user_type not in ['sector_vet', 'admin'] and not (user.is_staff or user.is_superuser):
        return Response({
            'error': 'You do not have permission to view dashboard statistics.'
        }, status=status.HTTP_403_FORBIDDEN)
    
    # Get statistics
    total_cases = CaseReport.objects.count()
    pending_cases = CaseReport.objects.filter(status='pending').count()
    resolved_cases = CaseReport.objects.filter(status='resolved').count()
    active_cases = CaseReport.objects.filter(
        status__in=['pending', 'under_review', 'diagnosed', 'treated']
    ).count()
    
    total_farmers = User.objects.filter(user_type='farmer').count()
    total_sector_vets = User.objects.filter(user_type='sector_vet').count()
    total_local_vets = User.objects.filter(user_type='local_vet').count()
    total_veterinarians = total_sector_vets + total_local_vets
    
    # Active veterinarians (online/available)
    from accounts.models import VeterinarianProfile
    active_veterinarians = VeterinarianProfile.objects.filter(is_available=True).count()
    
    total_livestock = Livestock.objects.count()
    healthy_livestock = Livestock.objects.filter(status='healthy').count()
    sick_livestock = Livestock.objects.filter(status='sick').count()
    
    # Get recent notifications count
    from datetime import timedelta
    recent_notifications = Notification.objects.filter(
        created_at__gte=timezone.now() - timedelta(days=7)
    ).count()
    
    # Calculate resolution rate
    resolution_rate = f"{(resolved_cases / total_cases * 100):.1f}%" if total_cases > 0 else "0%"
    
    # Return in format expected by frontend
    return Response({
        'total_cases': total_cases,
        'pending_cases': pending_cases,
        'resolved_cases': resolved_cases,
        'active_cases': active_cases,
        'total_farmers': total_farmers,
        'new_farmers_this_week': User.objects.filter(
            user_type='farmer',
            created_at__gte=timezone.now() - timedelta(days=7)
        ).count(),
        'total_veterinarians': total_veterinarians,
        'active_veterinarians': active_veterinarians,
        'total_livestock': total_livestock,
        'healthy_livestock': healthy_livestock,
        'sick_livestock': sick_livestock,
        'vaccinations_due': 0,  # Can be calculated if VaccinationRecord model exists
        'average_response_time': '0 hours',  # Can be calculated from consultations
        'resolution_rate': resolution_rate,
    }, status=status.HTTP_200_OK)
