class EntryModel {
  final String id;
  final String journalId;
  final String authorId;
  final String content;
  final DateTime createdAt;

  const EntryModel({
    required this.id,
    required this.journalId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  factory EntryModel.fromSupabaseRow(Map<String, dynamic> row) {
    return EntryModel(
      id: row['id'] as String,
      journalId: row['journal_id'] as String,
      authorId: row['author_id'] as String,
      content: row['content'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'journal_id': journalId,
      'author_id': authorId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    return EntryModel(
      id: json['id'] as String,
      journalId: json['journal_id'] as String,
      authorId: json['author_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool isAuthoredBy(String userId) => authorId == userId;

  String get preview {
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }
}
