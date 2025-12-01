"""
Case reporting and veterinary consultation models.
"""

from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from accounts.models import User
from livestock.models import Livestock


class Disease(models.Model):
    """Disease catalog for the system."""
    
    SEVERITY_CHOICES = [
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('critical', 'Critical'),
    ]
    
    name = models.CharField(max_length=200, unique=True)
    name_kinyarwanda = models.CharField(max_length=200, blank=True)
    name_french = models.CharField(max_length=200, blank=True)
    
    # Disease characteristics
    severity = models.CharField(max_length=20, choices=SEVERITY_CHOICES, default='medium')
    is_zoonotic = models.BooleanField(default=False)
    is_contagious = models.BooleanField(default=False)
    
    # Symptoms
    common_symptoms = models.TextField(blank=True)
    
    # Treatment information
    treatment_guidelines = models.TextField(blank=True)
    prevention_measures = models.TextField(blank=True)
    
    # Affected livestock types
    affected_livestock_types = models.ManyToManyField('livestock.LivestockType', blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'diseases'
        verbose_name = 'Disease'
        verbose_name_plural = 'Diseases'
    
    def __str__(self):
        return self.name


class CaseReport(models.Model):
    """Disease case reports from farmers."""
    
    STATUS_CHOICES = [
        ('pending', 'Pending Review'),
        ('under_review', 'Under Review'),
        ('investigation', 'Under Investigation'),
        ('diagnosed', 'Diagnosed'),
        ('treated', 'Treated'),
        ('resolved', 'Resolved'),
        ('rejected', 'Rejected'),
        ('escalated', 'Escalated'),
    ]
    
    URGENCY_CHOICES = [
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('urgent', 'Urgent'),
    ]
    
    # Basic information
    reporter = models.ForeignKey(User, on_delete=models.CASCADE, related_name='case_reports')
    livestock = models.ForeignKey(Livestock, on_delete=models.CASCADE, related_name='case_reports', null=True, blank=True, help_text="Optional: Specific livestock affected. Leave blank for general cases.")
    
    # Veterinarian assignment
    assigned_veterinarian = models.ForeignKey(
        User, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True,
        related_name='assigned_cases',
        help_text="Local veterinarian assigned to handle this case"
    )
    assigned_at = models.DateTimeField(null=True, blank=True)
    assigned_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='cases_assigned',
        help_text="Sector veterinarian or admin who assigned this case"
    )
    
    # Case details
    case_id = models.CharField(max_length=20, unique=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    urgency = models.CharField(max_length=20, choices=URGENCY_CHOICES, default='medium')
    
    # Symptoms and description
    symptoms_observed = models.TextField()
    duration_of_symptoms = models.CharField(max_length=100, blank=True)
    number_of_affected_animals = models.PositiveIntegerField(default=1)
    
    # Suspected disease
    suspected_disease = models.ForeignKey(Disease, on_delete=models.SET_NULL, null=True, blank=True)
    
    # Multimedia attachments
    photos = models.JSONField(default=list, blank=True)  # URLs to uploaded photos
    videos = models.JSONField(default=list, blank=True)  # URLs to uploaded videos
    audio_notes = models.JSONField(default=list, blank=True)  # URLs to audio files
    
    # Location information
    location_notes = models.TextField(blank=True)
    
    # Farmer confirmation for task completion
    farmer_confirmed_completion = models.BooleanField(
        default=False,
        help_text="Farmer confirmation that the task/assignment has been completed"
    )
    farmer_confirmed_at = models.DateTimeField(
        null=True,
        blank=True,
        help_text="Timestamp when farmer confirmed task completion"
    )
    
    # Timestamps
    reported_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'case_reports'
        verbose_name = 'Case Report'
        verbose_name_plural = 'Case Reports'
        ordering = ['-reported_at']
        indexes = [
            models.Index(fields=['status'], name='case_reports_status_idx'),
            models.Index(fields=['-reported_at'], name='case_reports_reported_idx'),
            models.Index(fields=['assigned_veterinarian'], name='case_reports_vet_idx'),
            models.Index(fields=['reporter'], name='case_reports_reporter_idx'),
            models.Index(fields=['status', 'reported_at'], name='case_reports_stat_rep_idx'),
        ]
    
    def __str__(self):
        return f"Case {self.case_id} - {self.livestock} ({self.status})"
    
    def save(self, *args, **kwargs):
        if not self.case_id:
            self.case_id = self.generate_case_id()
        super().save(*args, **kwargs)
    
    def generate_case_id(self):
        """Generate unique case ID."""
        from datetime import datetime
        timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
        return f"CR{timestamp}"


class VeterinaryConsultation(models.Model):
    """Veterinary consultations and advice."""
    
    case_report = models.ForeignKey(CaseReport, on_delete=models.CASCADE, related_name='consultations')
    veterinarian = models.ForeignKey(User, on_delete=models.CASCADE, related_name='consultations')
    
    # Consultation details
    consultation_date = models.DateTimeField(auto_now_add=True)
    consultation_type = models.CharField(
        max_length=50,
        choices=[
            ('initial_review', 'Initial Review'),
            ('follow_up', 'Follow-up'),
            ('emergency', 'Emergency Consultation'),
            ('teleconsultation', 'Teleconsultation'),
        ]
    )
    
    # Diagnosis and treatment
    diagnosis = models.TextField()
    treatment_plan = models.TextField()
    medications_prescribed = models.TextField(blank=True)
    dosage_instructions = models.TextField(blank=True)
    
    # Follow-up instructions
    follow_up_required = models.BooleanField(default=False)
    follow_up_date = models.DateField(null=True, blank=True)
    follow_up_instructions = models.TextField(blank=True)
    
    # Cost information
    consultation_fee = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    medication_cost = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    
    # Veterinarian notes
    veterinarian_notes = models.TextField(blank=True)
    
    class Meta:
        db_table = 'veterinary_consultations'
        verbose_name = 'Veterinary Consultation'
        verbose_name_plural = 'Veterinary Consultations'
        ordering = ['-consultation_date']
    
    def __str__(self):
        return f"Consultation for {self.case_report.case_id} by {self.veterinarian.full_name}"


class TreatmentFollowUp(models.Model):
    """Follow-up records for treatments."""
    
    consultation = models.ForeignKey(VeterinaryConsultation, on_delete=models.CASCADE, related_name='follow_ups')
    
    # Follow-up details
    follow_up_date = models.DateTimeField()
    follow_up_type = models.CharField(
        max_length=50,
        choices=[
            ('phone_call', 'Phone Call'),
            ('visit', 'Farm Visit'),
            ('teleconsultation', 'Teleconsultation'),
            ('self_report', 'Self Report'),
        ]
    )
    
    # Treatment response
    treatment_response = models.TextField()
    improvement_observed = models.BooleanField(default=False)
    side_effects = models.TextField(blank=True)
    
    # Additional notes
    additional_notes = models.TextField(blank=True)
    next_steps = models.TextField(blank=True)
    
    # Conducted by
    conducted_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'treatment_follow_ups'
        verbose_name = 'Treatment Follow-up'
        verbose_name_plural = 'Treatment Follow-ups'
        ordering = ['-follow_up_date']
    
    def __str__(self):
        return f"Follow-up for {self.consultation.case_report.case_id} ({self.follow_up_date})"


class OutbreakAlert(models.Model):
    """Disease outbreak alerts and notifications."""
    
    SEVERITY_CHOICES = [
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('critical', 'Critical'),
    ]
    
    # Alert information
    disease = models.ForeignKey(Disease, on_delete=models.CASCADE)
    title = models.CharField(max_length=200)
    description = models.TextField()
    severity = models.CharField(max_length=20, choices=SEVERITY_CHOICES)
    
    # Affected areas
    affected_districts = models.JSONField(default=list, blank=True)
    affected_sectors = models.JSONField(default=list, blank=True)
    
    # Recommendations
    prevention_measures = models.TextField()
    immediate_actions = models.TextField()
    vaccination_recommendations = models.TextField(blank=True)
    
    # Source information
    reported_by = models.ForeignKey(User, on_delete=models.CASCADE)
    source = models.CharField(max_length=200, blank=True)  # RAB, MINAGRI, etc.
    
    # Status
    is_active = models.BooleanField(default=True)
    alert_date = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField(null=True, blank=True)
    
    # Statistics
    affected_livestock_count = models.PositiveIntegerField(default=0)
    affected_farms_count = models.PositiveIntegerField(default=0)
    
    class Meta:
        db_table = 'outbreak_alerts'
        verbose_name = 'Outbreak Alert'
        verbose_name_plural = 'Outbreak Alerts'
        ordering = ['-alert_date']
    
    def __str__(self):
        return f"{self.disease.name} Alert - {self.alert_date.strftime('%Y-%m-%d')}"


class CaseStatistics(models.Model):
    """Statistics and analytics for case reports."""
    
    # Time period
    date = models.DateField()
    
    # Case counts
    total_cases_reported = models.PositiveIntegerField(default=0)
    cases_pending = models.PositiveIntegerField(default=0)
    cases_under_review = models.PositiveIntegerField(default=0)
    cases_resolved = models.PositiveIntegerField(default=0)
    
    # Disease breakdown
    disease_breakdown = models.JSONField(default=dict, blank=True)
    
    # Geographic breakdown
    district_breakdown = models.JSONField(default=dict, blank=True)
    
    # Response times
    average_response_time_hours = models.DecimalField(max_digits=6, decimal_places=2, default=0)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'case_statistics'
        verbose_name = 'Case Statistics'
        verbose_name_plural = 'Case Statistics'
        unique_together = ['date']
        ordering = ['-date']
    
    def __str__(self):
        return f"Case Statistics - {self.date}"
