from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework import status
from django.db import connection
from django.db.models import Count, Q
from django.utils import timezone
from django.conf import settings
from django.core.cache import cache
from datetime import timedelta
from accounts.models import User
from cases.models import CaseReport
from livestock.models import Livestock
from notifications.models import Notification
import logging

logger = logging.getLogger(__name__)

@api_view(['GET'])
@permission_classes([AllowAny])
def health_check(request):
    """Health check endpoint that pings the database to keep it alive and checks schema"""
    try:
        # Simple database query to keep connection alive
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
        
        # Check database schema for common issues
        schema_status = {}
        try:
            db_engine = connection.vendor
            if db_engine == 'postgresql':
                with connection.cursor() as cursor:
                    # Check if old password_reset_code column exists
                    cursor.execute("""
                        SELECT column_name 
                        FROM information_schema.columns 
                        WHERE table_name='users' AND column_name='password_reset_code'
                    """)
                    old_column = cursor.fetchone()
                    
                    # Check if new password_reset_token column exists
                    cursor.execute("""
                        SELECT column_name 
                        FROM information_schema.columns 
                        WHERE table_name='users' AND column_name='password_reset_token'
                    """)
                    new_column = cursor.fetchone()
                    
                    schema_status = {
                        'password_reset_code_exists': old_column is not None,
                        'password_reset_token_exists': new_column is not None,
                        'schema_issue': old_column is not None and new_column is None,
                    }
            else:
                # For other databases, skip schema check
                schema_status = {'note': f'Schema check skipped for {db_engine}'}
        except Exception as schema_error:
            schema_status = {'schema_check_error': str(schema_error)}
        
        response_data = {
            'status': 'healthy',
            'database': 'connected',
            'timestamp': timezone.now().isoformat(),
            'schema': schema_status,
        }
        
        # If schema issue detected, add warning
        if schema_status.get('schema_issue'):
            response_data['warning'] = 'Database schema mismatch detected. Run fix_database_schema.py to fix.'
            response_data['status'] = 'degraded'
        
        return Response(response_data, status=status.HTTP_200_OK)
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
    """Dashboard statistics endpoint with caching"""
    try:
        user = request.user
        user_type = user.user_type
        
        # Only sector vets and admins can see all stats
        if user_type not in ['sector_vet', 'admin'] and not (user.is_staff or user.is_superuser):
            return Response({
                'error': 'You do not have permission to view dashboard statistics.'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Try to get cached stats first (cache for 60 seconds)
        from django.core.cache import cache
        cache_key = 'dashboard_stats'
        cached_stats = cache.get(cache_key)
        if cached_stats:
            logger.info('Returning cached dashboard stats')
            return Response(cached_stats, status=status.HTTP_200_OK)
        
        # Optimize statistics queries using aggregation to reduce database hits
        
        # Get case statistics in fewer queries using aggregation
        case_stats = CaseReport.objects.aggregate(
            total=Count('id'),
            pending=Count('id', filter=Q(status='pending')),
            resolved=Count('id', filter=Q(status='resolved')),
            active=Count('id', filter=Q(status__in=['pending', 'under_review', 'diagnosed', 'treated']))
        )
        total_cases = case_stats['total'] or 0
        pending_cases = case_stats['pending'] or 0
        resolved_cases = case_stats['resolved'] or 0
        active_cases = case_stats['active'] or 0
        
        # Get user statistics using aggregation
        user_stats = User.objects.aggregate(
            farmers=Count('id', filter=Q(user_type='farmer')),
            sector_vets=Count('id', filter=Q(user_type='sector_vet')),
            local_vets=Count('id', filter=Q(user_type='local_vet'))
        )
        total_farmers = user_stats['farmers'] or 0
        total_sector_vets = user_stats['sector_vets'] or 0
        total_local_vets = user_stats['local_vets'] or 0
        total_veterinarians = total_sector_vets + total_local_vets
        
        # Active veterinarians (online/available)
        from accounts.models import VeterinarianProfile
        active_veterinarians = VeterinarianProfile.objects.filter(is_available=True).count()
        
        # Get livestock statistics using aggregation
        livestock_stats = Livestock.objects.aggregate(
            total=Count('id'),
            healthy=Count('id', filter=Q(status='healthy')),
            sick=Count('id', filter=Q(status='sick'))
        )
        total_livestock = livestock_stats['total'] or 0
        healthy_livestock = livestock_stats['healthy'] or 0
        sick_livestock = livestock_stats['sick'] or 0
        
        # Get recent notifications count
        recent_notifications = Notification.objects.filter(
            created_at__gte=timezone.now() - timedelta(days=7)
        ).count()
        
        # Calculate vaccinations due (from VaccinationRecord model)
        from livestock.models import VaccinationRecord
        today = timezone.now().date()
        vaccinations_due = VaccinationRecord.objects.filter(
            next_due_date__lte=today + timedelta(days=30),  # Due in next 30 days
            next_due_date__gte=today  # Not past due yet
        ).count()
        
        # Calculate average response time (optimized - only check recent 50 cases)
        average_response_time = '0 hours'
        try:
            # Only check most recent 50 cases for performance
            assigned_cases = CaseReport.objects.filter(
                assigned_at__isnull=False,
                reported_at__isnull=False
            ).order_by('-reported_at')[:50]  # Limit to 50 most recent cases
            
            if assigned_cases.exists():
                response_times = []
                # Use values() to avoid loading full objects
                for case_data in assigned_cases.values('reported_at', 'assigned_at'):
                    try:
                        reported_at = case_data.get('reported_at')
                        assigned_at = case_data.get('assigned_at')
                        if reported_at and assigned_at:
                            # Handle both datetime objects and strings
                            if isinstance(reported_at, str):
                                from django.utils.dateparse import parse_datetime
                                reported_at = parse_datetime(reported_at)
                            if isinstance(assigned_at, str):
                                from django.utils.dateparse import parse_datetime
                                assigned_at = parse_datetime(assigned_at)
                            
                            if reported_at and assigned_at:
                                time_diff = (assigned_at - reported_at).total_seconds() / 3600  # Hours
                                if time_diff > 0:  # Only count positive differences
                                    response_times.append(time_diff)
                    except (AttributeError, TypeError, ValueError) as e:
                        logger.warning(f"Error calculating response time for case: {e}")
                        continue
                
                if response_times:
                    avg_hours = sum(response_times) / len(response_times)
                    if avg_hours < 1:
                        average_response_time = f"{int(avg_hours * 60)} minutes"
                    elif avg_hours < 24:
                        average_response_time = f"{avg_hours:.1f} hours"
                    else:
                        average_response_time = f"{avg_hours / 24:.1f} days"
        except Exception as e:
            logger.error(f"Error calculating average response time: {e}", exc_info=True)
            average_response_time = 'N/A'  # Set to N/A if calculation fails
        
        # Calculate resolution rate
        resolution_rate = f"{(resolved_cases / total_cases * 100):.1f}%" if total_cases > 0 else "0%"
        
        # Prepare response data
        response_data = {
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
            'vaccinations_due': vaccinations_due,
            'average_response_time': average_response_time,
            'resolution_rate': resolution_rate,
        }
        
        # Cache the response for 60 seconds (dashboard auto-refreshes every 30s)
        cache.set(cache_key, response_data, 60)
        logger.info('Dashboard stats calculated and cached')
        
        return Response(response_data, status=status.HTTP_200_OK)
    except Exception as e:
        import logging
        import traceback
        logger = logging.getLogger(__name__)
        error_traceback = traceback.format_exc()
        logger.error(f"Error in dashboard stats: {str(e)}\n{error_traceback}", exc_info=True)
        
        # Return a more detailed error in debug mode
        error_detail = str(e) if settings.DEBUG else 'Please try again later.'
        if settings.DEBUG:
            error_detail = f"{str(e)}\n\nTraceback:\n{error_traceback}"
        
        return Response({
            'error': 'An error occurred while fetching dashboard statistics.',
            'detail': error_detail
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
