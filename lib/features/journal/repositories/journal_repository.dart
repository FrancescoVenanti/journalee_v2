import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/journal_model.dart';
import 'dart:math';

class JournalsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<JournalModel>> getUserJournals(String userId) async {
    try {
      // Get owned journals
      final ownedResponse = await _client
          .from('journals')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      // Get joined journals
      final joinedResponse = await _client
          .from('journal_members')
          .select('journals(*)')
          .eq('user_id', userId);

      final List<JournalModel> journals = [];

      // Add owned journals
      for (final row in ownedResponse) {
        journals.add(JournalModel.fromSupabaseRow(row));
      }

      // Add joined journals
      for (final row in joinedResponse) {
        final journalData = row['journals'];
        if (journalData != null) {
          journals.add(JournalModel.fromSupabaseRow(journalData));
        }
      }

      return journals;
    } catch (e) {
      throw Exception('Failed to fetch journals: $e');
    }
  }

  Future<JournalModel> createJournal({
    required String title,
    required String ownerId,
    required bool isShared,
  }) async {
    try {
      final code = _generateUniqueCode();

      final response = await _client
          .from('journals')
          .insert({
            'title': title,
            'owner_id': ownerId,
            'is_shared': isShared,
            'code': code,
          })
          .select()
          .single();

      return JournalModel.fromSupabaseRow(response);
    } catch (e) {
      throw Exception('Failed to create journal: $e');
    }
  }

  Future<JournalModel?> joinJournalByCode(String code, String userId) async {
    try {
      // Find journal by code
      final journalResponse = await _client
          .from('journals')
          .select()
          .eq('code', code)
          .eq('is_shared', true)
          .maybeSingle();

      if (journalResponse == null) {
        throw Exception('Journal not found or not shared');
      }

      final journal = JournalModel.fromSupabaseRow(journalResponse);

      // Check if user is already a member
      final existingMember = await _client
          .from('journal_members')
          .select()
          .eq('journal_id', journal.id)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMember == null) {
        // Add user as member
        await _client.from('journal_members').insert({
          'journal_id': journal.id,
          'user_id': userId,
        });
      }

      return journal;
    } catch (e) {
      throw Exception('Failed to join journal: $e');
    }
  }

  String _generateUniqueCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
          6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}
