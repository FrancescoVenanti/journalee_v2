import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../../shared/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StreamNotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

class AuthNotifier extends StreamNotifier<UserModel?> {
  @override
  Stream<UserModel?> build() {
    final repository = ref.read(authRepositoryProvider);
    return repository.authStateChanges;
  }

  Future<void> signUp(String email, String password) async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signUp(email, password);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signIn(email, password);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }
}
