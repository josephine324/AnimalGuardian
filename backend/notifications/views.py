from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from django.contrib.auth import get_user_model
from .models import Notification, BroadcastMessage
from .serializers import NotificationSerializer, BroadcastMessageSerializer

User = get_user_model()

class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for Notifications."""
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Notification.objects.filter(recipient=self.request.user)
    
    @action(detail=True, methods=['patch', 'put'])
    def mark_as_read(self, request, pk=None):
        """Mark a notification as read."""
        notification = self.get_object()
        
        # Ensure user can only mark their own notifications as read
        if notification.recipient != request.user:
            return Response(
                {'error': 'You can only mark your own notifications as read.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Update notification status
        notification.status = 'read'
        if not notification.read_at:
            notification.read_at = timezone.now()
        notification.save(update_fields=['status', 'read_at'])
        
        serializer = self.get_serializer(notification)
        return Response(serializer.data)
    
    @action(detail=False, methods=['post'])
    def mark_all_read(self, request):
        """Mark all notifications for the current user as read."""
        notifications = Notification.objects.filter(
            recipient=request.user,
            status__in=['pending', 'sent', 'delivered']
        )
        
        updated_count = notifications.update(
            status='read',
            read_at=timezone.now()
        )
        
        return Response({
            'message': f'Marked {updated_count} notifications as read.',
            'updated_count': updated_count
        })


class BroadcastMessageViewSet(viewsets.ModelViewSet):
    """ViewSet for Broadcast Messages."""
    queryset = BroadcastMessage.objects.all()
    serializer_class = BroadcastMessageSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # Only sector vets and admins can view broadcasts
        if self.request.user.user_type in ['sector_vet', 'admin'] or self.request.user.is_staff:
            return BroadcastMessage.objects.all()
        return BroadcastMessage.objects.none()
    
    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)
    
    @action(detail=True, methods=['post'])
    def send(self, request, pk=None):
        """Send a broadcast message to all target users."""
        broadcast = self.get_object()
        
        # Check permissions
        if request.user.user_type not in ['sector_vet', 'admin'] and not request.user.is_staff:
            return Response(
                {'error': 'Only sector veterinarians and admins can send broadcasts'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        try:
            # Get target users
            users = User.objects.filter(is_active=True)
            
            # Apply filters if specified
            if broadcast.target_districts:
                users = users.filter(district__in=broadcast.target_districts)
            if broadcast.target_sectors:
                users = users.filter(sector__in=broadcast.target_sectors)
            if broadcast.target_users:
                users = users.filter(id__in=broadcast.target_users)
            
            # Create notifications for each user
            notifications_created = 0
            for user in users:
                for channel in broadcast.channels or ['in_app']:
                    Notification.objects.create(
                        recipient=user,
                        channel=channel,
                        title=broadcast.title,
                        message=broadcast.message,
                        language=broadcast.language,
                        status='sent'
                    )
                    notifications_created += 1
            
            # Update broadcast status
            broadcast.status = 'sent'
            broadcast.sent_at = timezone.now()
            broadcast.total_recipients = users.count()
            broadcast.sent_count = notifications_created
            broadcast.save()
            
            return Response({
                'message': f'Broadcast sent successfully to {users.count()} users',
                'total_recipients': users.count(),
                'notifications_sent': notifications_created
            })
        except Exception as e:
            broadcast.status = 'failed'
            broadcast.save()
            return Response(
                {'error': f'Failed to send broadcast: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
