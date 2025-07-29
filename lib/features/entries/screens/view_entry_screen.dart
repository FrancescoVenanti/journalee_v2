import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journalee/features/entries/providers/entries_providers.dart';
import '../models/entry_model.dart';
import '../../auth/providers/auth_providers.dart';

class ViewEntryScreen extends ConsumerStatefulWidget {
  final String journalId;
  final String entryId;

  const ViewEntryScreen({
    super.key,
    required this.journalId,
    required this.entryId,
  });

  @override
  ConsumerState<ViewEntryScreen> createState() => _ViewEntryScreenState();
}

class _ViewEntryScreenState extends ConsumerState<ViewEntryScreen> {
  late QuillController _controller;
  EntryModel? _entry;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    _loadEntry();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadEntry() {
    final entriesAsync = ref.read(entriesProvider(widget.journalId));
    entriesAsync.whenData((entries) {
      final entry = entries.firstWhere((e) => e.id == widget.entryId);
      setState(() {
        _entry = entry;
      });

      // Try to parse as rich text JSON, fallback to plain text
      try {
        final deltaJson = jsonDecode(entry.content) as List;
        final document = Document.fromJson(deltaJson);
        _controller.document = document;
      } catch (e) {
        // Fallback: treat as plain text
        _controller.document = Document()..insert(0, entry.content);
      }
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await ref
                    .read(entriesProvider(widget.journalId).notifier)
                    .deleteEntry(widget.entryId);
                if (mounted) {
                  Navigator.of(context).pop();
                  context.go('/entries/${widget.journalId}?goback=true');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final isAuthor = _entry?.isAuthoredBy(user?.id ?? '') ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.go('/entries/${widget.journalId}?goback=true'),
        ),
        title: const Text('Journal Entry'),
        actions: [
          if (isAuthor)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showDeleteConfirmation,
              tooltip: 'Delete Entry',
            ),
        ],
      ),
      body: _entry == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Entry metadata
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAuthor ? Icons.person : Icons.group,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAuthor ? 'You' : 'Member',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(_entry!.createdAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Rich text content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: QuillEditor.basic(
                      controller: _controller,
                      config: const QuillEditorConfig(
                        padding: EdgeInsets.all(16.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
