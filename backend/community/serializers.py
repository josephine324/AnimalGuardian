from rest_framework import serializers
from .models import Post, PostLike, Comment, Conversation, Message


class CommentSerializer(serializers.ModelSerializer):
    author_name = serializers.SerializerMethodField()
    author_id = serializers.IntegerField(source='author.id', read_only=True)
    
    class Meta:
        model = Comment
        fields = ['id', 'post', 'author', 'author_id', 'author_name', 'content', 'created_at', 'updated_at']
        read_only_fields = ['author', 'created_at', 'updated_at']
    
    def get_author_name(self, obj):
        return obj.author.get_full_name() or obj.author.username


class PostSerializer(serializers.ModelSerializer):
    author_name = serializers.SerializerMethodField()
    author_id = serializers.IntegerField(source='author.id', read_only=True)
    comments = CommentSerializer(many=True, read_only=True)
    is_liked = serializers.SerializerMethodField()
    
    class Meta:
        model = Post
        fields = ['id', 'author', 'author_id', 'author_name', 'title', 'content', 'image', 'likes_count', 
                  'comments_count', 'is_liked', 'comments', 'created_at', 'updated_at']
        read_only_fields = ['author', 'likes_count', 'comments_count', 'created_at', 'updated_at']
    
    def get_author_name(self, obj):
        return obj.author.get_full_name() or obj.author.username
    
    def get_is_liked(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return PostLike.objects.filter(post=obj, user=request.user).exists()
        return False


class PostLikeSerializer(serializers.ModelSerializer):
    class Meta:
        model = PostLike
        fields = ['id', 'post', 'user', 'created_at']
        read_only_fields = ['user', 'created_at']


class MessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.SerializerMethodField()
    sender_id = serializers.IntegerField(source='sender.id', read_only=True)
    
    class Meta:
        model = Message
        fields = ['id', 'conversation', 'sender', 'sender_id', 'sender_name', 'content', 'is_read', 'created_at']
        read_only_fields = ['sender', 'created_at']
    
    def get_sender_name(self, obj):
        return obj.sender.get_full_name() or obj.sender.username


class ConversationSerializer(serializers.ModelSerializer):
    participant1_name = serializers.SerializerMethodField()
    participant1_id = serializers.IntegerField(source='participant1.id', read_only=True)
    participant2_name = serializers.SerializerMethodField()
    participant2_id = serializers.IntegerField(source='participant2.id', read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()
    other_participant = serializers.SerializerMethodField()
    
    class Meta:
        model = Conversation
        fields = [
            'id', 'participant1', 'participant1_id', 'participant1_name',
            'participant2', 'participant2_id', 'participant2_name',
            'other_participant', 'last_message', 'unread_count',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']
    
    def get_participant1_name(self, obj):
        return obj.participant1.get_full_name() or obj.participant1.username
    
    def get_participant2_name(self, obj):
        return obj.participant2.get_full_name() or obj.participant2.username
    
    def get_last_message(self, obj):
        last_msg = obj.get_last_message()
        if last_msg:
            return {
                'id': last_msg.id,
                'content': last_msg.content,
                'sender_id': last_msg.sender.id,
                'created_at': last_msg.created_at.isoformat(),
            }
        return None
    
    def get_unread_count(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.messages.filter(is_read=False).exclude(sender=request.user).count()
        return 0
    
    def get_other_participant(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            other = obj.get_other_participant(request.user)
            return {
                'id': other.id,
                'name': other.get_full_name() or other.username,
                'user_type': other.user_type,
            }
        return None

