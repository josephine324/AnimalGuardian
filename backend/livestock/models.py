"""
Livestock management models for AnimalGuardian system.
"""

from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from accounts.models import User


class LivestockType(models.Model):
    """Types of livestock in the system."""
    
    name = models.CharField(max_length=100, unique=True)
    name_kinyarwanda = models.CharField(max_length=100, blank=True)
    name_french = models.CharField(max_length=100, blank=True)
    
    # Characteristics
    average_lifespan_years = models.PositiveIntegerField(default=10)
    gestation_period_days = models.PositiveIntegerField(default=280)
    
    # Vaccination schedule (in days from birth)
    vaccination_schedule = models.JSONField(default=list, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'livestock_types'
        verbose_name = 'Livestock Type'
        verbose_name_plural = 'Livestock Types'
    
    def __str__(self):
        return self.name


class Breed(models.Model):
    """Breeds within livestock types."""
    
    livestock_type = models.ForeignKey(LivestockType, on_delete=models.CASCADE, related_name='breeds')
    name = models.CharField(max_length=100)
    name_kinyarwanda = models.CharField(max_length=100, blank=True)
    
    # Breed characteristics
    origin = models.CharField(max_length=100, blank=True)
    characteristics = models.TextField(blank=True)
    average_weight_kg = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'breeds'
        verbose_name = 'Breed'
        verbose_name_plural = 'Breeds'
        unique_together = ['livestock_type', 'name']
    
    def __str__(self):
        return f"{self.name} ({self.livestock_type.name})"


class Livestock(models.Model):
    """Individual livestock records."""
    
    GENDER_CHOICES = [
        ('M', 'Male'),
        ('F', 'Female'),
    ]
    
    STATUS_CHOICES = [
        ('healthy', 'Healthy'),
        ('sick', 'Sick'),
        ('pregnant', 'Pregnant'),
        ('in_heat', 'In Heat'),
        ('deceased', 'Deceased'),
        ('sold', 'Sold'),
    ]
    
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='livestock')
    livestock_type = models.ForeignKey(LivestockType, on_delete=models.CASCADE)
    breed = models.ForeignKey(Breed, on_delete=models.SET_NULL, null=True, blank=True)
    
    # Basic information
    name = models.CharField(max_length=100, blank=True)
    tag_number = models.CharField(max_length=50, unique=True, blank=True, null=True)
    gender = models.CharField(max_length=1, choices=GENDER_CHOICES)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='healthy')
    
    # Physical characteristics
    birth_date = models.DateField(null=True, blank=True)
    weight_kg = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)
    color = models.CharField(max_length=50, blank=True)
    description = models.TextField(blank=True)
    
    # Health information
    last_vaccination_date = models.DateField(null=True, blank=True)
    last_deworming_date = models.DateField(null=True, blank=True)
    last_health_check = models.DateField(null=True, blank=True)
    
    # Reproduction (for females)
    is_pregnant = models.BooleanField(default=False)
    pregnancy_start_date = models.DateField(null=True, blank=True)
    expected_delivery_date = models.DateField(null=True, blank=True)
    last_heat_date = models.DateField(null=True, blank=True)
    next_expected_heat = models.DateField(null=True, blank=True)
    
    # Production data (for dairy animals)
    daily_milk_production_liters = models.DecimalField(
        max_digits=6, 
        decimal_places=2, 
        null=True, 
        blank=True
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'livestock'
        verbose_name = 'Livestock'
        verbose_name_plural = 'Livestock'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status'], name='livestock_status_idx'),
            models.Index(fields=['owner'], name='livestock_owner_idx'),
            models.Index(fields=['-created_at'], name='livestock_created_at_idx'),
        ]
    
    def save(self, *args, **kwargs):
        """Override save to ensure empty tag_number is converted to None."""
        if self.tag_number is not None and isinstance(self.tag_number, str) and not self.tag_number.strip():
            self.tag_number = None
        super().save(*args, **kwargs)
    
    def __str__(self):
        return f"{self.name or self.tag_number} ({self.livestock_type.name})"
    
    @property
    def age_months(self):
        """Calculate age in months."""
        if self.birth_date:
            from datetime import date
            today = date.today()
            return (today.year - self.birth_date.year) * 12 + (today.month - self.birth_date.month)
        return None


class VaccinationRecord(models.Model):
    """Vaccination records for livestock."""
    
    livestock = models.ForeignKey(Livestock, on_delete=models.CASCADE, related_name='vaccinations')
    vaccine_name = models.CharField(max_length=200)
    vaccine_type = models.CharField(max_length=100, blank=True)
    
    vaccination_date = models.DateField()
    next_due_date = models.DateField()
    
    # Vaccination details
    batch_number = models.CharField(max_length=50, blank=True)
    dosage = models.CharField(max_length=50, blank=True)
    route = models.CharField(max_length=50, blank=True)  # IM, IV, Subcutaneous, etc.
    
    # Veterinarian information
    veterinarian = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    clinic_name = models.CharField(max_length=200, blank=True)
    
    # Notes
    notes = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'vaccination_records'
        verbose_name = 'Vaccination Record'
        verbose_name_plural = 'Vaccination Records'
        ordering = ['-vaccination_date']
    
    def __str__(self):
        return f"{self.livestock} - {self.vaccine_name} ({self.vaccination_date})"


class HealthRecord(models.Model):
    """Health check and treatment records."""
    
    livestock = models.ForeignKey(Livestock, on_delete=models.CASCADE, related_name='health_records')
    
    # Health check information
    check_date = models.DateField()
    check_type = models.CharField(
        max_length=50,
        choices=[
            ('routine', 'Routine Check'),
            ('sick_visit', 'Sick Visit'),
            ('pregnancy_check', 'Pregnancy Check'),
            ('vaccination', 'Vaccination'),
            ('deworming', 'Deworming'),
        ]
    )
    
    # Health status
    temperature = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    weight = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)
    heart_rate = models.PositiveIntegerField(null=True, blank=True)
    respiratory_rate = models.PositiveIntegerField(null=True, blank=True)
    
    # Findings
    symptoms = models.TextField(blank=True)
    diagnosis = models.TextField(blank=True)
    treatment = models.TextField(blank=True)
    medications_prescribed = models.TextField(blank=True)
    
    # Veterinarian information
    veterinarian = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    
    # Follow-up
    follow_up_required = models.BooleanField(default=False)
    follow_up_date = models.DateField(null=True, blank=True)
    follow_up_notes = models.TextField(blank=True)
    
    # Cost
    consultation_fee = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    medication_cost = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'health_records'
        verbose_name = 'Health Record'
        verbose_name_plural = 'Health Records'
        ordering = ['-check_date']
    
    def __str__(self):
        return f"{self.livestock} - {self.check_type} ({self.check_date})"


class MilkProduction(models.Model):
    """Daily milk production records (for dairy animals)."""
    
    livestock = models.ForeignKey(Livestock, on_delete=models.CASCADE, related_name='milk_records')
    
    production_date = models.DateField()
    morning_production = models.DecimalField(max_digits=6, decimal_places=2, default=0)
    afternoon_production = models.DecimalField(max_digits=6, decimal_places=2, default=0)
    evening_production = models.DecimalField(max_digits=6, decimal_places=2, default=0)
    
    # Quality indicators
    fat_content = models.DecimalField(max_digits=4, decimal_places=2, null=True, blank=True)
    protein_content = models.DecimalField(max_digits=4, decimal_places=2, null=True, blank=True)
    
    # Notes
    notes = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'milk_production'
        verbose_name = 'Milk Production'
        verbose_name_plural = 'Milk Production Records'
        unique_together = ['livestock', 'production_date']
        ordering = ['-production_date']
    
    def __str__(self):
        return f"{self.livestock} - {self.production_date}"
    
    @property
    def total_production(self):
        """Calculate total daily production."""
        return self.morning_production + self.afternoon_production + self.evening_production
