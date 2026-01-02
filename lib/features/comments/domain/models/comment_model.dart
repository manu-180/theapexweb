// Archivo: lib/features/comments/domain/models/comment_model.dart
class Comment {
  final int id;
  final String content;
  final String userName;
  final String? avatarUrl;
  final DateTime createdAt;
  final int likesCount;
  final bool isLikedByMe;
  final int? parentId;
  final String userId;
  final int? rating;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.content,
    required this.userName,
    this.avatarUrl,
    required this.createdAt,
    required this.likesCount,
    required this.isLikedByMe,
    this.parentId,
    required this.userId,
    this.rating,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      userName: json['user_name'] ?? 'Usuario Anónimo',
      avatarUrl: json['avatar_url'],
      likesCount: json['likes_count'] ?? 0,
      isLikedByMe: json['is_liked_by_me'] ?? false,
      parentId: json['parent_id'],
      userId: json['user_id'],
      rating: json['rating'],
    );
  }
  
  Comment copyWith({
    int? likesCount,
    bool? isLikedByMe,
    List<Comment>? replies,
    int? rating,
  }) {
    return Comment(
      id: id,
      content: content,
      userName: userName,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      parentId: parentId,
      userId: userId,
      rating: rating ?? this.rating,
      replies: replies ?? this.replies,
    );
  }
}