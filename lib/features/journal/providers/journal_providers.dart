import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journalee/features/journal/repositories/journal_repository.dart';
import '../models/journal_model.dart';
import '../../auth/providers/auth_providers.dart';

final journalsRepositoryProvider = Provider<JournalsRepository>((ref) {
  return JournalsRepository();
});

final journalsProvider =
    AsyncNotifierProvider<JournalsNotifier, List<JournalModel>>(() {
  return JournalsNotifier();
});

class JournalsNotifier extends AsyncNotifier<List<JournalModel>> {
  @override
  Future<List<JournalModel>> build() async {
    final repository = ref.read(journalsRepositoryProvider);

    final user = ref.watch(authProvider).value;
    if (user == null) {
      return [];
    }

    return await repository.getUserJournals(user.id);
  }

  Future<void> createJournal(String title, bool isShared) async {
    final user = ref.read(authProvider).value;
    if (user == null) throw Exception('User not authenticated');

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(journalsRepositoryProvider);
      await repository.createJournal(
        title: title,
        ownerId: user.id,
        isShared: isShared,
      );

      // Refresh the list
      final journals = await repository.getUserJournals(user.id);
      state = AsyncValue.data(journals);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> joinJournal(String code) async {
    final user = ref.read(authProvider).value;
    if (user == null) throw Exception('User not authenticated');

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(journalsRepositoryProvider);
      await repository.joinJournalByCode(code, user.id);

      // Refresh the list
      final journals = await repository.getUserJournals(user.id);
      state = AsyncValue.data(journals);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(journalsRepositoryProvider);
      final journals = await repository.getUserJournals(user.id);
      state = AsyncValue.data(journals);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
