from rest_framework import serializers
from .models import Notification, BroadcastMessage

class NotificationSerializer(serializers.ModelSerializer):
    is_read = serializers.SerializerMethodField()
    
    class Meta:
        model = Notification
        fields = '__all__'
    
    def get_is_read(self, obj):
        """Check if notification is read based on status and read_at."""
        return obj.status == 'read' or obj.read_at is not None

class BroadcastMessageSerializer(serializers.ModelSerializer):
    created_by_name = serializers.CharField(source='created_by.get_full_name', read_only=True)
    
    class Meta:
        model = BroadcastMessage
        fields = '__all__'
        read_only_fields = ('created_by', 'status', 'sent_at', 'total_recipients', 'sent_count', 'delivered_count', 'failed_count')
