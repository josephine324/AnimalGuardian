from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Q
from accounts.models import User
from .models import Post, PostLike, Comment, Conversation, Message
from .serializers import (
    PostSerializer, PostLikeSerializer, CommentSerializer,
    ConversationSerializer, MessageSerializer
)


class PostViewSet(viewsets.ModelViewSet):
    """ViewSet for community posts."""
    queryset = Post.objects.all()
    serializer_class = PostSerializer
    permission_classes = [IsAuthenticated]
    
    def perform_create(self, serializer):
        serializer.save(author=self.request.user)
    
    @action(detail=True, methods=['post'])
    def like(self, request, pk=None):
        """Like or unlike a post."""
        post = self.get_object()
        like, created = PostLike.objects.get_or_create(
            post=post,
            user=request.user
        )
        
        if not created:
            like.delete()
            post.likes_count = max(0, post.likes_count - 1)
            liked = False
        else:
            post.likes_count += 1
            liked = True
        
        post.save()
        return Response({'liked': liked, 'likes_count': post.likes_count})


class CommentViewSet(viewsets.ModelViewSet):
    """ViewSet for post comments."""
    queryset = Comment.objects.all()
    serializer_class = CommentSerializer
    permission_classes = [IsAuthenticated]
    
    def perform_create(self, serializer):
        serializer.save(author=self.request.user)
        # Update post comments count
        post = serializer.validated_data['post']
        post.comments_count += 1
        post.save()


class ConversationViewSet(viewsets.ModelViewSet):
    """ViewSet for chat conversations."""
    serializer_class = ConversationSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Get conversations where the current user is a participant."""
        user = self.request.user
        return Conversation.objects.filter(
            Q(participant1=user) | Q(participant2=user)
        ).distinct()
    
    def get_serializer_context(self):
        """Add request to serializer context."""
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
    
    @action(detail=False, methods=['get'])
    def with_user(self, request):
        """Get or create a conversation with a specific user."""
        user_id = request.query_params.get('user_id')
        if not user_id:
            return Response(
                {'error': 'user_id parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            other_user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response(
                {'error': 'User not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        if other_user == request.user:
            return Response(
                {'error': 'Cannot create conversation with yourself'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check if conversation already exists
        conversation = Conversation.objects.filter(
            (Q(participant1=request.user) & Q(participant2=other_user)) |
            (Q(participant1=other_user) & Q(participant2=request.user))
        ).first()
        
        if not conversation:
            # Create new conversation
            conversation = Conversation.objects.create(
                participant1=request.user,
                participant2=other_user
            )
        
        serializer = self.get_serializer(conversation)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def mark_read(self, request, pk=None):
        """Mark all messages in conversation as read."""
        conversation = self.get_object()
        
        # Only mark messages sent by the other participant as read
        other_participant = conversation.get_other_participant(request.user)
        conversation.messages.filter(
            sender=other_participant,
            is_read=False
        ).update(is_read=True)
        
        return Response({'message': 'Messages marked as read'})


class MessageViewSet(viewsets.ModelViewSet):
    """ViewSet for chat messages."""
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Get messages for a specific conversation."""
        conversation_id = self.request.query_params.get('conversation_id')
        if conversation_id:
            # Verify user is a participant in the conversation
            conversation = Conversation.objects.filter(
                id=conversation_id
            ).filter(
                Q(participant1=self.request.user) | Q(participant2=self.request.user)
            ).first()
            
            if conversation:
                return Message.objects.filter(conversation=conversation)
        
        return Message.objects.none()
    
    def perform_create(self, serializer):
        """Create a new message."""
        conversation = serializer.validated_data['conversation']
        
        # Verify user is a participant
        if conversation.participant1 != self.request.user and conversation.participant2 != self.request.user:
            raise PermissionError("You are not a participant in this conversation")
        
        message = serializer.save(sender=self.request.user)
        
        # Update conversation's updated_at timestamp
        conversation.save()
        
        return message
    
    @action(detail=True, methods=['post'])
    def mark_read(self, request, pk=None):
        """Mark a message as read."""
        message = self.get_object()
        
        # Only mark as read if the current user is the recipient
        if message.sender != request.user:
            message.is_read = True
            message.save()
            return Response({'message': 'Message marked as read'})
        
        return Response(
            {'error': 'Cannot mark your own message as read'},
            status=status.HTTP_400_BAD_REQUEST
        )

