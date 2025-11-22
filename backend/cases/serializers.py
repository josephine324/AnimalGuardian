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
    livestock_id = serializers.IntegerField(
        write_only=True,
        required=False,
        allow_null=True
    )
    
    # Make case_id and reporter read-only (auto-generated/set by backend)
    case_id = serializers.CharField(read_only=True)
    reporter = serializers.PrimaryKeyRelatedField(read_only=True)
    
    def get_livestock(self, obj):
        """Return nested livestock data using LivestockSerializer."""
        try:
            if obj.livestock:
                # Lazy import to avoid circular dependencies
                from livestock.serializers import LivestockSerializer
                return LivestockSerializer(obj.livestock).data
        except Exception as e:
            # Log error but don't crash - return basic livestock info instead
            import logging
            logger = logging.getLogger(__name__)
            logger.warning(f"Error serializing livestock for case {obj.id}: {e}")
            # Return basic info if full serialization fails
            if obj.livestock:
                return {
                    'id': obj.livestock.id,
                    'name': getattr(obj.livestock, 'name', None),
                    'tag_number': getattr(obj.livestock, 'tag_number', None),
                }
        return None
    
    def create(self, validated_data):
        """Override create to handle livestock_id assignment."""
        livestock_id = validated_data.pop('livestock_id', None)
        case = super().create(validated_data)
        if livestock_id is not None:
            from livestock.models import Livestock
            try:
                case.livestock = Livestock.objects.get(id=livestock_id) if livestock_id else None
                case.save()
            except Livestock.DoesNotExist:
                pass  # Invalid livestock_id, leave as None
        return case
    
    def update(self, instance, validated_data):
        """Override update to handle livestock_id assignment."""
        livestock_id = validated_data.pop('livestock_id', None)
        case = super().update(instance, validated_data)
        if livestock_id is not None:
            from livestock.models import Livestock
            try:
                case.livestock = Livestock.objects.get(id=livestock_id) if livestock_id else None
                case.save()
            except Livestock.DoesNotExist:
                case.livestock = None
                case.save()
        return case
    
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
