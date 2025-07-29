import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String email;

  const UserModel({
    required this.id,
    required this.email,
  });

  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
    );
  }
}
