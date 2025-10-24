from rest_framework import serializers
from .models import CaseReport, Disease

class DiseaseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Disease
        fields = '__all__'

class CaseReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = CaseReport
        fields = '__all__'
