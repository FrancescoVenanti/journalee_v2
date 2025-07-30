import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:journalee/features/entries/providers/entries_providers.dart';
import '../models/entry_model.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';

class EntriesScreen extends ConsumerWidget {
  final String journalId;

  const EntriesScreen({
    super.key,
    required this.journalId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(entriesProvider(journalId));
    final user = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/journals?goback=true'),
        ),
        title: Text(
          'Journal Entries',
          style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () =>
                ref.read(entriesProvider(journalId).notifier).refresh(),
          ),
        ],
      ),
      body: entriesAsync.when(
          data: (entries) =>
              _buildEntriesList(context, ref, entries, user?.id ?? ''),
          loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
          error: (error, stack) {
            debugPrint(error.toString());
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Something went wrong',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(entriesProvider(journalId).notifier).refresh(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.medium,
        ),
        child: FloatingActionButton(
          onPressed: () => context.go('/create-entry/$journalId'),
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          child: const Icon(Icons.edit, size: 24),
        ),
      ),
    );
  }

  Widget _buildEntriesList(BuildContext context, WidgetRef ref,
      List<EntryModel> entries, String currentUserId) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Your journal awaits',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Write your first entry to get started',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: entries.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isAuthor = entry.isAuthoredBy(currentUserId);

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider, width: 1),
            boxShadow: AppShadows.soft,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: () => context.go('/view-entry/$journalId/${entry.id}'),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with author info and timestamp
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: isAuthor
                                ? AppColors.accentSoft
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAuthor ? Icons.person : Icons.group,
                                size: 12,
                                color: isAuthor
                                    ? AppColors.accent
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                isAuthor ? 'You' : entry.authorDisplayName,
                                style: AppTextStyles.caption.copyWith(
                                  color: isAuthor
                                      ? AppColors.accent
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(entry.createdAt),
                          style: AppTextStyles.caption,
                        ),
                        if (isAuthor) ...[
                          const SizedBox(width: AppSpacing.sm),
                          InkWell(
                            onTap: () =>
                                _showDeleteConfirmation(context, ref, entry),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: const Padding(
                              padding: EdgeInsets.all(AppSpacing.xs),
                              child: Icon(
                                Icons.more_vert,
                                size: 16,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Content preview
                    _buildContentPreview(entry.content),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentPreview(String content) {
    // Try to parse as Quill delta JSON first
    try {
      final List<dynamic> deltaOps = jsonDecode(content);
      return _buildRichTextFromDelta(deltaOps);
    } catch (e) {
      // If it fails, treat as plain text
      return Text(
        content,
        style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _buildRichTextFromDelta(List<dynamic> deltaOps) {
    List<TextSpan> spans = [];

    for (var op in deltaOps) {
      if (op is Map<String, dynamic> && op.containsKey('insert')) {
        String text = op['insert'].toString();
        Map<String, dynamic>? attributes = op['attributes'];

        // Build text style based on attributes
        TextStyle style = AppTextStyles.bodyLarge.copyWith(height: 1.6);

        if (attributes != null) {
          if (attributes.containsKey('bold') && attributes['bold'] == true) {
            style = style.copyWith(fontWeight: FontWeight.w600);
          }
          if (attributes.containsKey('italic') &&
              attributes['italic'] == true) {
            style = style.copyWith(fontStyle: FontStyle.italic);
          }
          if (attributes.containsKey('underline') &&
              attributes['underline'] == true) {
            style = style.copyWith(decoration: TextDecoration.underline);
          }
        }

        spans.add(TextSpan(text: text, style: style));
      }
    }

    if (spans.isEmpty) {
      return Text(
        'Empty entry',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
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

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, EntryModel entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        title: Text(
          'Delete Entry',
          style: AppTextStyles.heading3,
        ),
        content: Text(
          'Are you sure you want to delete this entry? This action cannot be undone.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            onPressed: () async {
              try {
                await ref
                    .read(entriesProvider(journalId).notifier)
                    .deleteEntry(entry.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
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
}
