from rest_framework import serializers
from .models import CaseReport, Disease

class DiseaseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Disease
        fields = '__all__'

class CaseReportSerializer(serializers.ModelSerializer):
    reporter_name = serializers.SerializerMethodField()
    assigned_veterinarian_name = serializers.SerializerMethodField()
    assigned_by_name = serializers.SerializerMethodField()
    
    class Meta:
        model = CaseReport
        fields = '__all__'
    
    def get_reporter_name(self, obj):
        return obj.reporter.get_full_name() or obj.reporter.username if obj.reporter else None
    
    def get_assigned_veterinarian_name(self, obj):
        return obj.assigned_veterinarian.get_full_name() or obj.assigned_veterinarian.username if obj.assigned_veterinarian else None
    
    def get_assigned_by_name(self, obj):
        return obj.assigned_by.get_full_name() or obj.assigned_by.username if obj.assigned_by else None
