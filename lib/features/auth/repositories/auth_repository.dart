import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/user_model.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserModel?> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return UserModel.fromSupabaseUser(response.user!);
      }
      return null;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return UserModel.fromSupabaseUser(response.user!);
      }
      return null;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  UserModel? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user != null) {
      return UserModel.fromSupabaseUser(user);
    }
    return null;
  }

  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user != null) {
        return UserModel.fromSupabaseUser(user);
      }
      return null;
    });
  }
}
