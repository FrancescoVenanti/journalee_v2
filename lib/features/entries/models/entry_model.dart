class EntryModel {
  final String id;
  final String journalId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final String? authorUsername;
  final String? authorEmail;

  const EntryModel({
    required this.id,
    required this.journalId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.authorUsername,
    this.authorEmail,
  });

  factory EntryModel.fromSupabaseRow(Map<String, dynamic> row) {
    return EntryModel(
      id: row['id'] as String,
      journalId: row['journal_id'] as String,
      authorId: row['author_id'] as String,
      content: row['content'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      authorUsername: row['author_username'] as String?,
      authorEmail: row['author_email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'journal_id': journalId,
      'author_id': authorId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'author_username': authorUsername,
      'author_email': authorEmail,
    };
  }

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    return EntryModel(
      id: json['id'] as String,
      journalId: json['journal_id'] as String,
      authorId: json['author_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorUsername: json['author_username'] as String?,
      authorEmail: json['author_email'] as String?,
    );
  }

  bool isAuthoredBy(String userId) => authorId == userId;

  String get authorDisplayName {
    if (authorUsername != null && authorUsername!.isNotEmpty) {
      return authorUsername!;
    }
    if (authorEmail != null && authorEmail!.isNotEmpty) {
      return authorEmail!;
    }
    return 'Unknown';
  }

  String get preview {
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }
}
