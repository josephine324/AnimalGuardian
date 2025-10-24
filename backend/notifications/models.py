"""
Notification system models for AnimalGuardian.
"""

from django.db import models
from django.contrib.auth import get_user_model
from livestock.models import Livestock
from cases.models import CaseReport, OutbreakAlert

User = get_user_model()


class NotificationTemplate(models.Model):
    """Templates for different types of notifications."""
    
    TEMPLATE_TYPE_CHOICES = [
        ('vaccination_reminder', 'Vaccination Reminder'),
        ('pregnancy_check', 'Pregnancy Check'),
        ('health_check', 'Health Check'),
        ('disease_alert', 'Disease Alert'),
        ('outbreak_warning', 'Outbreak Warning'),
        ('case_update', 'Case Update'),
        ('system_announcement', 'System Announcement'),
        ('weather_alert', 'Weather Alert'),
    ]
    
    name = models.CharField(max_length=100)
    template_type = models.CharField(max_length=50, choices=TEMPLATE_TYPE_CHOICES)
    
    # Message templates in different languages
    message_english = models.TextField()
    message_kinyarwanda = models.TextField()
    message_french = models.TextField()
    
    # Template variables
    variables = models.JSONField(default=list, blank=True)  # List of variable names used in template
    
    # Settings
    is_active = models.BooleanField(default=True)
    priority = models.IntegerField(default=1)  # 1=low, 2=medium, 3=high, 4=urgent
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'notification_templates'
        verbose_name = 'Notification Template'
        verbose_name_plural = 'Notification Templates'
    
    def __str__(self):
        return f"{self.name} ({self.template_type})"


class Notification(models.Model):
    """Individual notifications sent to users."""
    
    CHANNEL_CHOICES = [
        ('sms', 'SMS'),
        ('ussd', 'USSD'),
        ('push', 'Push Notification'),
        ('email', 'Email'),
        ('in_app', 'In-App'),
    ]
    
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('sent', 'Sent'),
        ('delivered', 'Delivered'),
        ('failed', 'Failed'),
        ('read', 'Read'),
    ]
    
    # Recipient information
    recipient = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    channel = models.CharField(max_length=20, choices=CHANNEL_CHOICES)
    
    # Message content
    title = models.CharField(max_length=200, blank=True)
    message = models.TextField()
    language = models.CharField(max_length=10, default='rw')
    
    # Template reference
    template = models.ForeignKey(NotificationTemplate, on_delete=models.SET_NULL, null=True, blank=True)
    
    # Related objects
    related_livestock = models.ForeignKey(Livestock, on_delete=models.CASCADE, null=True, blank=True)
    related_case = models.ForeignKey(CaseReport, on_delete=models.CASCADE, null=True, blank=True)
    related_alert = models.ForeignKey(OutbreakAlert, on_delete=models.CASCADE, null=True, blank=True)
    
    # Status and delivery
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    sent_at = models.DateTimeField(null=True, blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)
    read_at = models.DateTimeField(null=True, blank=True)
    
    # Error handling
    error_message = models.TextField(blank=True)
    retry_count = models.PositiveIntegerField(default=0)
    max_retries = models.PositiveIntegerField(default=3)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    scheduled_for = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'notifications'
        verbose_name = 'Notification'
        verbose_name_plural = 'Notifications'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['recipient', 'status']),
            models.Index(fields=['scheduled_for']),
            models.Index(fields=['channel', 'status']),
        ]
    
    def __str__(self):
        return f"{self.recipient.phone_number} - {self.channel} - {self.status}"


class NotificationSchedule(models.Model):
    """Scheduled notifications for recurring events."""
    
    SCHEDULE_TYPE_CHOICES = [
        ('vaccination', 'Vaccination Reminder'),
        ('pregnancy_check', 'Pregnancy Check'),
        ('health_check', 'Health Check'),
        ('deworming', 'Deworming Reminder'),
        ('heat_detection', 'Heat Detection'),
        ('milking', 'Milking Reminder'),
    ]
    
    # Schedule information
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notification_schedules')
    livestock = models.ForeignKey(Livestock, on_delete=models.CASCADE, related_name='notification_schedules')
    schedule_type = models.CharField(max_length=50, choices=SCHEDULE_TYPE_CHOICES)
    
    # Timing
    start_date = models.DateField()
    end_date = models.DateField(null=True, blank=True)
    frequency_days = models.PositiveIntegerField(default=30)
    time_of_day = models.TimeField(default='09:00')
    
    # Notification settings
    advance_notice_days = models.PositiveIntegerField(default=1)
    channels = models.JSONField(default=list)  # ['sms', 'push', etc.]
    
    # Status
    is_active = models.BooleanField(default=True)
    last_sent = models.DateTimeField(null=True, blank=True)
    next_scheduled = models.DateTimeField(null=True, blank=True)
    
    # Custom message
    custom_message = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'notification_schedules'
        verbose_name = 'Notification Schedule'
        verbose_name_plural = 'Notification Schedules'
        unique_together = ['user', 'livestock', 'schedule_type']
    
    def __str__(self):
        return f"{self.user.full_name} - {self.livestock} - {self.schedule_type}"


class NotificationPreference(models.Model):
    """User notification preferences."""
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='notification_preferences')
    
    # Channel preferences
    enable_sms = models.BooleanField(default=True)
    enable_push = models.BooleanField(default=True)
    enable_email = models.BooleanField(default=False)
    enable_ussd = models.BooleanField(default=True)
    
    # Content preferences
    enable_vaccination_reminders = models.BooleanField(default=True)
    enable_pregnancy_reminders = models.BooleanField(default=True)
    enable_health_check_reminders = models.BooleanField(default=True)
    enable_disease_alerts = models.BooleanField(default=True)
    enable_outbreak_warnings = models.BooleanField(default=True)
    enable_case_updates = models.BooleanField(default=True)
    enable_weather_alerts = models.BooleanField(default=True)
    
    # Timing preferences
    quiet_hours_start = models.TimeField(default='22:00')
    quiet_hours_end = models.TimeField(default='06:00')
    enable_quiet_hours = models.BooleanField(default=True)
    
    # Language preference
    preferred_language = models.CharField(
        max_length=10,
        choices=[
            ('en', 'English'),
            ('rw', 'Kinyarwanda'),
            ('fr', 'French'),
        ],
        default='rw'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'notification_preferences'
        verbose_name = 'Notification Preference'
        verbose_name_plural = 'Notification Preferences'
    
    def __str__(self):
        return f"Preferences for {self.user.phone_number}"


class NotificationLog(models.Model):
    """Log of notification delivery attempts and results."""
    
    notification = models.ForeignKey(Notification, on_delete=models.CASCADE, related_name='logs')
    
    # Delivery attempt
    attempt_number = models.PositiveIntegerField()
    attempted_at = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, choices=Notification.STATUS_CHOICES)
    
    # Provider response
    provider_message_id = models.CharField(max_length=200, blank=True)
    provider_response = models.JSONField(default=dict, blank=True)
    
    # Error details
    error_code = models.CharField(max_length=50, blank=True)
    error_message = models.TextField(blank=True)
    
    class Meta:
        db_table = 'notification_logs'
        verbose_name = 'Notification Log'
        verbose_name_plural = 'Notification Logs'
        ordering = ['-attempted_at']
    
    def __str__(self):
        return f"Log {self.attempt_number} for {self.notification}"


class BroadcastMessage(models.Model):
    """Broadcast messages sent to multiple users."""
    
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('scheduled', 'Scheduled'),
        ('sending', 'Sending'),
        ('sent', 'Sent'),
        ('failed', 'Failed'),
    ]
    
    # Message content
    title = models.CharField(max_length=200)
    message = models.TextField()
    language = models.CharField(max_length=10, default='rw')
    
    # Targeting
    target_users = models.JSONField(default=list, blank=True)  # List of user IDs
    target_criteria = models.JSONField(default=dict, blank=True)  # Filter criteria
    target_districts = models.JSONField(default=list, blank=True)
    target_sectors = models.JSONField(default=list, blank=True)
    
    # Delivery settings
    channels = models.JSONField(default=list)  # ['sms', 'push', 'ussd']
    scheduled_for = models.DateTimeField(null=True, blank=True)
    
    # Status
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='draft')
    sent_at = models.DateTimeField(null=True, blank=True)
    
    # Statistics
    total_recipients = models.PositiveIntegerField(default=0)
    sent_count = models.PositiveIntegerField(default=0)
    delivered_count = models.PositiveIntegerField(default=0)
    failed_count = models.PositiveIntegerField(default=0)
    
    # Creator
    created_by = models.ForeignKey(User, on_delete=models.CASCADE)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'broadcast_messages'
        verbose_name = 'Broadcast Message'
        verbose_name_plural = 'Broadcast Messages'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.title} - {self.status}"
