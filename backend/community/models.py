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

