class JournalModel {
  final String id;
  final String title;
  final String ownerId;
  final bool isShared;
  final String code;
  final DateTime createdAt;

  const JournalModel({
    required this.id,
    required this.title,
    required this.ownerId,
    required this.isShared,
    required this.code,
    required this.createdAt,
  });

  factory JournalModel.fromSupabaseRow(Map<String, dynamic> row) {
    return JournalModel(
      id: row['id'] as String,
      title: row['title'] as String,
      ownerId: row['owner_id'] as String,
      isShared: row['is_shared'] as bool,
      code: row['code'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'owner_id': ownerId,
      'is_shared': isShared,
      'code': code,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: json['id'] as String,
      title: json['title'] as String,
      ownerId: json['owner_id'] as String,
      isShared: json['is_shared'] as bool,
      code: json['code'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool isOwnedBy(String userId) => ownerId == userId;

  String get displayTitle => title.isEmpty ? 'Untitled Journal' : title;
}
