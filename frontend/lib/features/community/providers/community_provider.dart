import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/community_model.dart';
import '../../../core/services/api_service.dart';

class CommunityState {
  final List<Post> posts;
  final List<Post> filteredPosts;
  final Map<int, List<Comment>> comments;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final String searchQuery;
  final PostType? selectedType;

  const CommunityState({
    this.posts = const [],
    this.filteredPosts = const [],
    this.comments = const {},
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.searchQuery = '',
    this.selectedType,
  });

  CommunityState copyWith({
    List<Post>? posts,
    List<Post>? filteredPosts,
    Map<int, List<Comment>>? comments,
    bool? isLoading,
    String? error,
    bool? hasMore,
    String? searchQuery,
    PostType? selectedType,
    bool clearError = false,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      filteredPosts: filteredPosts ?? this.filteredPosts,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

class CommunityNotifier extends StateNotifier<CommunityState> {
  CommunityNotifier() : super(const CommunityState()) {
    loadPosts(refresh: true);
  }

  final ApiService _apiService = ApiService();
  int _currentPage = 1;

  Future<void> loadPosts({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      _currentPage = 1;
      state = state.copyWith(
        posts: const [],
        filteredPosts: const [],
        hasMore: true,
        isLoading: true,
        clearError: true,
      );
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final posts = await _apiService.getPosts(
        type: state.selectedType,
        page: _currentPage,
      );

      final merged = refresh ? posts : [...state.posts, ...posts];
      state = state.copyWith(
        posts: merged,
        filteredPosts: _filterPosts(merged, state.searchQuery, state.selectedType),
        isLoading: false,
        hasMore: posts.length >= AppConstants.defaultPageSize,
      );

      if (posts.isNotEmpty) {
        _currentPage++;
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    await loadPosts();
  }

  void updateSearch(String query) {
    final trimmed = query.trimLeft();
    if (trimmed == state.searchQuery) return;

    state = state.copyWith(
      searchQuery: trimmed,
      filteredPosts: _filterPosts(state.posts, trimmed, state.selectedType),
    );
  }

  void setPostType(PostType? type) {
    if (type == state.selectedType) return;
    state = state.copyWith(
      selectedType: type,
      filteredPosts: _filterPosts(state.posts, state.searchQuery, type),
    );
    loadPosts(refresh: true);
  }

  Future<void> loadComments(int postId) async {
    try {
      final comments = await _apiService.getComments(postId);
      final updatedComments = Map<int, List<Comment>>.from(state.comments);
      updatedComments[postId] = comments;
      state = state.copyWith(comments: updatedComments);
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<Post?> createPost(Map<String, dynamic> payload) async {
    try {
      final post = await _apiService.createPost(payload);
      final updatedPosts = [post, ...state.posts];
      state = state.copyWith(
        posts: updatedPosts,
        filteredPosts: _filterPosts(updatedPosts, state.searchQuery, state.selectedType),
      );
      return post;
    } catch (error) {
      state = state.copyWith(error: error.toString());
      return null;
    }
  }

  Future<Comment?> createComment(Map<String, dynamic> payload) async {
    try {
      final comment = await _apiService.createComment(payload);
      await loadComments(comment.postId);
      return comment;
    } catch (error) {
      state = state.copyWith(error: error.toString());
      return null;
    }
  }

  Future<void> likePost(int postId) async {
    try {
      final result = await _apiService.likePost(postId);
      final updatedPosts = state.posts.map((post) {
        if (post.id != postId) return post;
        return Post(
          id: post.id,
          authorId: post.authorId,
          authorName: post.authorName,
          authorUsername: post.authorUsername,
          title: post.title,
          content: post.content,
          postType: post.postType,
          images: post.images,
          likesCount: result['likes_count'] ?? post.likesCount,
          commentsCount: post.commentsCount,
          viewsCount: post.viewsCount,
          tags: post.tags,
          isPinned: post.isPinned,
          isApproved: post.isApproved,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
          isLiked: result['liked'] ?? !post.isLiked,
        );
      }).toList();

      state = state.copyWith(
        posts: updatedPosts,
        filteredPosts: _filterPosts(updatedPosts, state.searchQuery, state.selectedType),
      );
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  List<Post> _filterPosts(List<Post> posts, String query, PostType? type) {
    Iterable<Post> filtered = posts;

    if (type != null) {
      filtered = filtered.where((post) => post.postType == type);
    }

    if (query.trim().isEmpty) {
      return filtered.toList();
    }

    final lower = query.toLowerCase();
    return filtered.where((post) {
      final titleMatch = post.title.toLowerCase().contains(lower);
      final contentMatch = post.content.toLowerCase().contains(lower);
      final authorMatch = post.authorName.toLowerCase().contains(lower);
      final tagMatch = post.tags.any((tag) => tag.toLowerCase().contains(lower));
      return titleMatch || contentMatch || authorMatch || tagMatch;
    }).toList();
  }
}

final communityProvider = StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier();
});

