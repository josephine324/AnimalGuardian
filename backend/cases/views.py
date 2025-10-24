from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import CaseReport, Disease
from .serializers import CaseReportSerializer, DiseaseSerializer

class CaseReportViewSet(viewsets.ModelViewSet):
    """ViewSet for Case reports."""
    queryset = CaseReport.objects.all()
    serializer_class = CaseReportSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return CaseReport.objects.filter(reporter=self.request.user)

class DiseaseViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for Diseases."""
    queryset = Disease.objects.all()
    serializer_class = DiseaseSerializer
