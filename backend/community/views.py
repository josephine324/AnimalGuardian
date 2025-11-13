from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import Post, PostLike, Comment
from .serializers import PostSerializer, PostLikeSerializer, CommentSerializer


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

