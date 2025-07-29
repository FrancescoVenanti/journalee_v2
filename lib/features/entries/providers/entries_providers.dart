import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journalee/features/entries/repositories/entry_repository.dart';
import '../models/entry_model.dart';
import '../../auth/providers/auth_providers.dart';

final entriesRepositoryProvider = Provider<EntriesRepository>((ref) {
  return EntriesRepository();
});

final entriesProvider =
    AsyncNotifierProvider.family<EntriesNotifier, List<EntryModel>, String>(() {
  return EntriesNotifier();
});

class EntriesNotifier extends FamilyAsyncNotifier<List<EntryModel>, String> {
  @override
  Future<List<EntryModel>> build(String journalId) async {
    final repository = ref.read(entriesRepositoryProvider);
    return await repository.getJournalEntries(journalId);
  }

  Future<void> createEntry(String content) async {
    final user = ref.read(authProvider).value;
    if (user == null) throw Exception('User not authenticated');

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(entriesRepositoryProvider);
      await repository.createEntry(
        journalId: arg,
        authorId: user.id,
        content: content,
      );

      // Refresh the list
      final entries = await repository.getJournalEntries(arg);
      state = AsyncValue.data(entries);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteEntry(String entryId) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(entriesRepositoryProvider);
      await repository.deleteEntry(entryId);

      // Refresh the list
      final entries = await repository.getJournalEntries(arg);
      state = AsyncValue.data(entries);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(entriesRepositoryProvider);
      final entries = await repository.getJournalEntries(arg);
      state = AsyncValue.data(entries);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
