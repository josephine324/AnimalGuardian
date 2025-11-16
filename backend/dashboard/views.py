from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Count, Q, Avg
from django.utils import timezone
from datetime import timedelta
from accounts.models import User
from cases.models import CaseReport
from livestock.models import Livestock, VaccinationRecord


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def dashboard_stats(request):
    """Get dashboard statistics."""
    
    # Case statistics
    total_cases = CaseReport.objects.count()
    pending_cases = CaseReport.objects.filter(status='pending').count()
    resolved_cases = CaseReport.objects.filter(status='resolved').count()
    active_cases = CaseReport.objects.filter(
        status__in=['pending', 'under_review', 'diagnosed', 'treated']
    ).count()
    
    # Calculate average response time (time from reported_at to first consultation)
    from cases.models import VeterinaryConsultation
    consultations = VeterinaryConsultation.objects.all()
    if consultations.exists():
        response_times = []
        for consultation in consultations:
            case = consultation.case_report
            if case.reported_at and consultation.consultation_date:
                delta = consultation.consultation_date - case.reported_at
                response_times.append(delta.total_seconds() / 3600)  # Convert to hours
        
        if response_times:
            avg_response_time_hours = sum(response_times) / len(response_times)
            average_response_time = f"{avg_response_time_hours:.1f} hours"
        else:
            average_response_time = "0 hours"
    else:
        average_response_time = "0 hours"
    
    # Calculate resolution rate
    if total_cases > 0:
        resolution_rate = f"{(resolved_cases / total_cases) * 100:.1f}%"
    else:
        resolution_rate = "0%"
    
    # User statistics
    total_farmers = User.objects.filter(user_type='farmer').count()
    week_ago = timezone.now() - timedelta(days=7)
    new_farmers_this_week = User.objects.filter(
        user_type='farmer',
        created_at__gte=week_ago
    ).count()
    
    # Count both sector and local veterinarians
    total_veterinarians = User.objects.filter(
        user_type__in=['sector_vet', 'local_vet']
    ).count()
    active_veterinarians = User.objects.filter(
        user_type__in=['sector_vet', 'local_vet'],
        vet_profile__is_available=True
    ).count()
    
    # Separate counts
    total_sector_vets = User.objects.filter(user_type='sector_vet').count()
    total_local_vets = User.objects.filter(user_type='local_vet').count()
    
    # Livestock statistics
    total_livestock = Livestock.objects.count()
    healthy_livestock = Livestock.objects.filter(status='healthy').count()
    sick_livestock = Livestock.objects.filter(status='sick').count()
    
    # Vaccinations due (next 30 days)
    today = timezone.now().date()
    next_month = today + timedelta(days=30)
    vaccinations_due = VaccinationRecord.objects.filter(
        next_due_date__gte=today,
        next_due_date__lte=next_month
    ).count()
    
    return Response({
        'total_cases': total_cases,
        'pending_cases': pending_cases,
        'resolved_cases': resolved_cases,
        'active_cases': active_cases,
        'total_farmers': total_farmers,
        'new_farmers_this_week': new_farmers_this_week,
        'total_veterinarians': total_veterinarians,
        'active_veterinarians': active_veterinarians,
        'total_sector_vets': total_sector_vets,
        'total_local_vets': total_local_vets,
        'total_livestock': total_livestock,
        'healthy_livestock': healthy_livestock,
        'sick_livestock': sick_livestock,
        'vaccinations_due': vaccinations_due,
        'average_response_time': average_response_time,
        'resolution_rate': resolution_rate,
    })

