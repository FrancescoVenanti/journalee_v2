import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/entry_model.dart';

class EntriesRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<EntryModel>> getJournalEntries(String journalId) async {
    try {
      final response = await _client
          .from('entries')
          .select('''
            *,
            profiles:author_id (
              username,
              email
            )
          ''')
          .eq('journal_id', journalId)
          .order('created_at', ascending: false);

      return response.map((row) {
        final profile = row['profiles'] as Map<String, dynamic>?;
        return EntryModel.fromSupabaseRow({
          ...row,
          'author_username': profile?['username'],
          'author_email': profile?['email'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch entries: $e');
    }
  }

  Future<EntryModel> createEntry({
    required String journalId,
    required String authorId,
    required String content,
  }) async {
    try {
      final response = await _client
          .from('entries')
          .insert({
            'journal_id': journalId,
            'author_id': authorId,
            'content': content,
          })
          .select()
          .single();

      return EntryModel.fromSupabaseRow(response);
    } catch (e) {
      throw Exception('Failed to create entry: $e');
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await _client.from('entries').delete().eq('id', entryId);
    } catch (e) {
      throw Exception('Failed to delete entry: $e');
    }
  }
}
