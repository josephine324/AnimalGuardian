from rest_framework import serializers
from .models import CaseReport, Disease

class DiseaseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Disease
        fields = '__all__'

class CaseReportSerializer(serializers.ModelSerializer):
    reporter_name = serializers.SerializerMethodField()
    reporter_phone = serializers.SerializerMethodField()
    reporter_email = serializers.SerializerMethodField()
    reporter_sector = serializers.SerializerMethodField()
    reporter_district = serializers.SerializerMethodField()
    assigned_veterinarian_name = serializers.SerializerMethodField()
    assigned_veterinarian_phone = serializers.SerializerMethodField()
    assigned_veterinarian_email = serializers.SerializerMethodField()
    assigned_by_name = serializers.SerializerMethodField()
    
    # Include nested livestock data so web dashboard can display it
    # Use lazy import to avoid circular dependencies
    livestock = serializers.SerializerMethodField()
    livestock_id = serializers.PrimaryKeyRelatedField(
        queryset=None,  # Will be set in __init__
        source='livestock',
        write_only=True,
        required=False,
        allow_null=True
    )
    
    # Make case_id and reporter read-only (auto-generated/set by backend)
    case_id = serializers.CharField(read_only=True)
    reporter = serializers.PrimaryKeyRelatedField(read_only=True)
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Set the queryset for livestock_id after models are loaded
        from livestock.models import Livestock
        self.fields['livestock_id'].queryset = Livestock.objects.all()
    
    def get_livestock(self, obj):
        """Return nested livestock data using LivestockSerializer."""
        if obj.livestock:
            # Lazy import to avoid circular dependencies
            from livestock.serializers import LivestockSerializer
            return LivestockSerializer(obj.livestock).data
        return None
    
    class Meta:
        model = CaseReport
        fields = '__all__'
        # Farmers can update: symptoms, duration, number of animals, location, urgency, photos, videos, audio
        # But cannot change: case_id, reporter, assigned_veterinarian, assigned_at, assigned_by, reported_at
        # updated_at is auto-updated by Django
        read_only_fields = ('case_id', 'reporter', 'assigned_veterinarian', 'assigned_at', 'assigned_by', 'reported_at', 'updated_at')
    
    def get_reporter_name(self, obj):
        return obj.reporter.get_full_name() or obj.reporter.username if obj.reporter else None
    
    def get_reporter_phone(self, obj):
        return obj.reporter.phone_number if obj.reporter else None
    
    def get_reporter_email(self, obj):
        return obj.reporter.email if obj.reporter else None
    
    def get_reporter_sector(self, obj):
        return obj.reporter.sector if obj.reporter else None
    
    def get_reporter_district(self, obj):
        return obj.reporter.district if obj.reporter else None
    
    def get_assigned_veterinarian_name(self, obj):
        return obj.assigned_veterinarian.get_full_name() or obj.assigned_veterinarian.username if obj.assigned_veterinarian else None
    
    def get_assigned_veterinarian_phone(self, obj):
        return obj.assigned_veterinarian.phone_number if obj.assigned_veterinarian else None
    
    def get_assigned_veterinarian_email(self, obj):
        return obj.assigned_veterinarian.email if obj.assigned_veterinarian else None
    
    def get_assigned_by_name(self, obj):
        return obj.assigned_by.get_full_name() or obj.assigned_by.username if obj.assigned_by else None
