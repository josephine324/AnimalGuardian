"""
User account models for AnimalGuardian system.
"""

from django.contrib.auth.models import AbstractUser
from django.db import models
from django.core.validators import RegexValidator


class User(AbstractUser):
    """Custom user model for AnimalGuardian system."""
    
    USER_TYPE_CHOICES = [
        ('farmer', 'Farmer'),
        ('sector_vet', 'Sector Veterinarian'),
        ('local_vet', 'Local Veterinarian'),
        ('admin', 'Admin'),
        ('field_officer', 'Field Officer'),
    ]
    
    GENDER_CHOICES = [
        ('M', 'Male'),
        ('F', 'Female'),
    ]
    
    user_type = models.CharField(
        max_length=20, 
        choices=USER_TYPE_CHOICES,
        default='farmer'
    )
    
    phone_regex = RegexValidator(
        regex=r'^(078|079|073|072)\d{7}$',
        message="Phone number must start with 078, 079, 073, or 072 and be exactly 10 digits (e.g., 0781234567)"
    )
    
    phone_number = models.CharField(
        validators=[phone_regex], 
        max_length=10, 
        unique=True,
        help_text="Rwanda phone number starting with 078, 079, 073, or 072 (10 digits total, e.g., 0781234567)"
    )
    
    # Override email field from AbstractUser to make it optional
    # Note: unique=True will be added back via migration once duplicates are fixed
    email = models.EmailField(blank=True, null=True, unique=False)
    
    gender = models.CharField(max_length=1, choices=GENDER_CHOICES, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    # profile_picture = models.ImageField(upload_to='profiles/', null=True, blank=True)  # Temporarily disabled
    
    # Location information
    province = models.CharField(max_length=100, blank=True)
    district = models.CharField(max_length=100, blank=True)
    sector = models.CharField(max_length=100, blank=True)
    cell = models.CharField(max_length=100, blank=True)
    village = models.CharField(max_length=100, blank=True)
    
    # Language preferences
    preferred_language = models.CharField(
        max_length=10,
        choices=[
            ('en', 'English'),
            ('rw', 'Kinyarwanda'),
            ('fr', 'French'),
        ],
        default='rw'
    )
    
    # Account verification
    is_verified = models.BooleanField(default=False)
    verification_code = models.CharField(max_length=6, blank=True)
    
    # Admin/Vet approval
    is_approved_by_admin = models.BooleanField(
        default=False,
        help_text="User must be approved by admin or sector veterinarian before they can login"
    )
    approved_by = models.ForeignKey(
        'self',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='approved_users',
        help_text="Admin or sector veterinarian who approved this user"
    )
    approved_at = models.DateTimeField(null=True, blank=True)
    approval_notes = models.TextField(blank=True, help_text="Notes from admin/vet about approval")
    
    # Password reset
    password_reset_token = models.CharField(max_length=100, blank=True, null=True, unique=True)
    password_reset_expires_at = models.DateTimeField(null=True, blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    USERNAME_FIELD = 'phone_number'
    REQUIRED_FIELDS = ['username']  # Email is optional
    
    class Meta:
        db_table = 'users'
        verbose_name = 'User'
        verbose_name_plural = 'Users'
    
    def __str__(self):
        return f"{self.get_full_name()} ({self.phone_number})"
    
    @property
    def full_name(self):
        return f"{self.first_name} {self.last_name}".strip()


class VeterinarianProfile(models.Model):
    """Extended profile for veterinarians."""
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='vet_profile')
    
    LICENSE_CHOICES = [
        ('licensed', 'Licensed Veterinarian'),
        ('assistant', 'Veterinary Assistant'),
        ('technician', 'Veterinary Technician'),
    ]
    
    license_number = models.CharField(max_length=50, unique=True)
    license_type = models.CharField(max_length=20, choices=LICENSE_CHOICES)
    specialization = models.CharField(max_length=100, blank=True)
    
    # Work location
    clinic_name = models.CharField(max_length=200, blank=True)
    clinic_address = models.TextField(blank=True)
    
    # Availability
    is_available = models.BooleanField(default=False, help_text="Veterinarian must explicitly set themselves to online via the app")
    working_hours = models.JSONField(default=dict, blank=True)
    
    # Experience and ratings
    years_of_experience = models.PositiveIntegerField(default=0)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.00)
    total_cases_handled = models.PositiveIntegerField(default=0)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'veterinarian_profiles'
        verbose_name = 'Veterinarian Profile'
        verbose_name_plural = 'Veterinarian Profiles'
    
    def __str__(self):
        return f"Dr. {self.user.full_name} ({self.license_number})"


class FarmerProfile(models.Model):
    """Extended profile for farmers."""
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='farmer_profile')
    
    # Farm information
    farm_name = models.CharField(max_length=200, blank=True)
    farm_size = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    farm_size_unit = models.CharField(
        max_length=10,
        choices=[
            ('hectares', 'Hectares'),
            ('acres', 'Acres'),
        ],
        default='hectares'
    )
    
    # Livestock information
    total_livestock_count = models.PositiveIntegerField(default=0)
    
    # Experience
    years_of_farming = models.PositiveIntegerField(default=0)
    
    # Technology access
    has_smartphone = models.BooleanField(default=False)
    has_basic_phone = models.BooleanField(default=True)
    has_internet_access = models.BooleanField(default=False)
    
    # Preferences
    preferred_communication = models.CharField(
        max_length=20,
        choices=[
            ('sms', 'SMS'),
            ('ussd', 'USSD'),
            ('app', 'Mobile App'),
            ('call', 'Phone Call'),
        ],
        default='sms'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'farmer_profiles'
        verbose_name = 'Farmer Profile'
        verbose_name_plural = 'Farmer Profiles'
    
    def __str__(self):
        return f"{self.user.full_name} - {self.farm_name}"


class OTPVerification(models.Model):
    """OTP verification for phone numbers."""
    
    phone_number = models.CharField(max_length=17)
    otp_code = models.CharField(max_length=6)
    is_used = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    
    class Meta:
        db_table = 'otp_verifications'
        verbose_name = 'OTP Verification'
        verbose_name_plural = 'OTP Verifications'
    
    def __str__(self):
        return f"OTP for {self.phone_number}"
