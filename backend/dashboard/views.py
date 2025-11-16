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
    active_cases = CaseReport.objects.filter(status='active').count()
    
    total_farmers = User.objects.filter(user_type='farmer').count()
    total_sector_vets = User.objects.filter(user_type='sector_vet').count()
    total_local_vets = User.objects.filter(user_type='local_vet').count()
    total_veterinarians = total_sector_vets + total_local_vets
    
    total_livestock = Livestock.objects.count()
    
    # Get recent notifications count
    recent_notifications = Notification.objects.filter(
        created_at__gte=timezone.now() - timezone.timedelta(days=7)
    ).count()
    
    return Response({
        'cases': {
            'total': total_cases,
            'pending': pending_cases,
            'resolved': resolved_cases,
            'active': active_cases,
        },
        'users': {
            'total_farmers': total_farmers,
            'total_sector_vets': total_sector_vets,
            'total_local_vets': total_local_vets,
            'total_veterinarians': total_veterinarians,
        },
        'livestock': {
            'total': total_livestock,
        },
        'notifications': {
            'recent_7_days': recent_notifications,
        },
        'timestamp': timezone.now().isoformat(),
    }, status=status.HTTP_200_OK)
