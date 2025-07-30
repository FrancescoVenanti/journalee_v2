import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/user_model.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserModel?> signUp(
      String email, String password, String username) async {
    try {
      // Check if username is already taken
      final existingProfile = await _client
          .from('profiles')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (existingProfile != null) {
        throw Exception('Username is already taken');
      }

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username}, // Store in user metadata for trigger
      );

      if (response.user != null) {
        return UserModel(
          id: response.user!.id,
          email: email,
          username: username,
        );
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
        return await _getUserWithProfile(response.user!.id);
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

  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user != null) {
      return await _getUserWithProfile(user.id);
    }
    return null;
  }

  Future<UserModel?> _getUserWithProfile(String userId) async {
    try {
      final profile =
          await _client.from('profiles').select().eq('id', userId).single();

      return UserModel.fromProfile(profile);
    } catch (e) {
      // Fallback to user metadata if profile doesn't exist
      final user = _client.auth.currentUser;
      if (user != null) {
        return UserModel.fromSupabaseUser(user);
      }
      return null;
    }
  }

  Future<void> updateUsername(String newUsername) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Check if username is already taken
      final existingProfile = await _client
          .from('profiles')
          .select()
          .eq('username', newUsername)
          .neq('id', user.id)
          .maybeSingle();

      if (existingProfile != null) {
        throw Exception('Username is already taken');
      }

      await _client.from('profiles').update({
        'username': newUsername,
      }).eq('id', user.id);
    } catch (e) {
      throw Exception('Failed to update username: $e');
    }
  }

  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user != null) {
        return await _getUserWithProfile(user.id);
      }
      return null;
    });
  }
}
