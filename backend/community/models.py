from django.db import models
from accounts.models import User


class Post(models.Model):
    """Community posts."""
    
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='posts')
    title = models.CharField(max_length=200)
    content = models.TextField()
    image = models.URLField(blank=True)  # URL to uploaded image
    
    # Engagement
    likes_count = models.PositiveIntegerField(default=0)
    comments_count = models.PositiveIntegerField(default=0)
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        app_label = 'community'
        db_table = 'community_posts'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.title} by {self.author.full_name}"


class PostLike(models.Model):
    """Post likes."""
    
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='likes')
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        app_label = 'community'
        db_table = 'community_post_likes'
        unique_together = ['post', 'user']
    
    def __str__(self):
        return f"{self.user.full_name} liked {self.post.title}"


class Comment(models.Model):
    """Post comments."""
    
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='comments')
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='comments')
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        app_label = 'community'
        db_table = 'community_comments'
        ordering = ['created_at']
    
    def __str__(self):
        return f"Comment by {self.author.full_name} on {self.post.title}"


class Conversation(models.Model):
    """Chat conversation between two users."""
    
    participant1 = models.ForeignKey(
        User, 
        on_delete=models.CASCADE, 
        related_name='conversations_as_participant1'
    )
    participant2 = models.ForeignKey(
        User, 
        on_delete=models.CASCADE, 
        related_name='conversations_as_participant2'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        app_label = 'community'
        db_table = 'community_conversations'
        unique_together = ['participant1', 'participant2']
        ordering = ['-updated_at']
    
    def __str__(self):
        return f"Conversation between {self.participant1.full_name} and {self.participant2.full_name}"
    
    def get_other_participant(self, user):
        """Get the other participant in the conversation."""
        if user == self.participant1:
            return self.participant2
        return self.participant1
    
    def get_last_message(self):
        """Get the last message in the conversation."""
        return self.messages.order_by('-created_at').first()


class Message(models.Model):
    """Chat message in a conversation."""
    
    conversation = models.ForeignKey(
        Conversation, 
        on_delete=models.CASCADE, 
        related_name='messages'
    )
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    content = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        app_label = 'community'
        db_table = 'community_messages'
        ordering = ['created_at']
    
    def __str__(self):
        return f"Message from {self.sender.full_name} in conversation {self.conversation.id}"