enum PostType {
  question,
  tip,
  experience,
  announcement,
  general,
}

extension PostTypeExtension on PostType {
  String get name {
    switch (this) {
      case PostType.question:
        return 'Question';
      case PostType.tip:
        return 'Tip';
      case PostType.experience:
        return 'Experience';
      case PostType.announcement:
        return 'Announcement';
      case PostType.general:
        return 'General';
    }
  }

  String get apiValue {
    switch (this) {
      case PostType.question:
        return 'question';
      case PostType.tip:
        return 'tip';
      case PostType.experience:
        return 'experience';
      case PostType.announcement:
        return 'announcement';
      case PostType.general:
        return 'general';
    }
  }

  static PostType fromString(String value) {
    switch (value) {
      case 'question':
        return PostType.question;
      case 'tip':
        return PostType.tip;
      case 'experience':
        return PostType.experience;
      case 'announcement':
        return PostType.announcement;
      case 'general':
        return PostType.general;
      default:
        return PostType.general;
    }
  }
}

class Post {
  final int id;
  final int authorId;
  final String authorName;
  final String authorUsername;
  final String title;
  final String content;
  final PostType postType;
  final List<String> images;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final List<String> tags;
  final bool isPinned;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLiked;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    required this.title,
    required this.content,
    required this.postType,
    required this.images,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.tags,
    required this.isPinned,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
    required this.isLiked,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    // Handle both author (int) and author_id
    final authorId = map['author'] is int 
        ? map['author'] as int 
        : (map['author_id'] as int? ?? 0);
    
    // Handle image field - backend uses 'image' (single URL), frontend expects 'images' (list)
    final imageUrl = map['image'] as String?;
    final images = imageUrl != null && imageUrl.isNotEmpty 
        ? [imageUrl] 
        : <String>[];
    
    return Post(
      id: map['id'] as int,
      authorId: authorId,
      authorName: map['author_name'] ?? '',
      authorUsername: map['author_username'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      postType: PostTypeExtension.fromString(map['post_type'] ?? 'general'),
      images: images,
      likesCount: map['likes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,
      viewsCount: map['views_count'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      isPinned: map['is_pinned'] ?? false,
      isApproved: map['is_approved'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isLiked: map['is_liked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': authorId,
      'title': title,
      'content': content,
      'post_type': postType.apiValue,
      'images': images,
      'tags': tags,
    };
  }
}

class Comment {
  final int id;
  final int postId;
  final int authorId;
  final String authorName;
  final String authorUsername;
  final String content;
  final int? parentId;
  final int likesCount;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLiked;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    required this.content,
    this.parentId,
    required this.likesCount,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
    required this.isLiked,
    required this.replies,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as int,
      postId: map['post'] as int,
      authorId: map['author'] is int 
          ? map['author'] as int 
          : (map['author_id'] as int? ?? 0),
      authorName: map['author_name'] ?? '',
      authorUsername: map['author_username'] ?? '',
      content: map['content'] ?? '',
      parentId: map['parent'] as int?,
      likesCount: map['likes_count'] ?? 0,
      isApproved: map['is_approved'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isLiked: map['is_liked'] ?? false,
      replies: (map['replies'] as List<dynamic>?)
              ?.map((r) => Comment.fromMap(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'post': postId,
      'content': content,
      if (parentId != null) 'parent': parentId,
    };
  }
}

