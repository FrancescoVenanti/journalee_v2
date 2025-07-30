import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journal_model.dart';
import '../providers/journal_providers.dart';
import '../../../../core/theme/app_theme.dart';

// Journal dialogs utility class
class JournalDialogs {
  // Show share code dialog
  static void showShareCode(BuildContext context, JournalModel journal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Row(
          children: [
            Icon(Icons.share, color: AppColors.accent, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text('Share Journal', style: AppTextStyles.heading3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share this code with others to let them join "${journal.displayTitle}"',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Text('Journal Code',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textTertiary)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    journal.code,
                    style: AppTextStyles.heading2.copyWith(
                      fontFamily: 'monospace',
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Others can join by entering this code in the "Join Journal" option.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            onPressed: () => _copyToClipboard(context, journal.code),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy Code'),
          ),
        ],
      ),
    );
  }

  // Show create journal dialog
  static void showCreateDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    bool isShared = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          title: Text('Create Journal', style: AppTextStyles.heading3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Journal Title',
                  labelStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Checkbox(
                    value: isShared,
                    onChanged: (value) =>
                        setState(() => isShared = value ?? false),
                    activeColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xs)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Make it shared', style: AppTextStyles.bodyMedium),
                        Text(
                          'Others can join with a code',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
              onPressed: () => _createJournal(
                  context, ref, titleController.text.trim(), isShared),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  // Show join journal dialog
  static void showJoinDialog(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text('Join Journal', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the 6-character code to join a shared journal',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              style: AppTextStyles.bodyMedium.copyWith(
                fontFamily: 'monospace',
                letterSpacing: 2.0,
              ),
              decoration: InputDecoration(
                labelText: 'Journal Code',
                hintText: 'ABC123',
                labelStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                  fontFamily: 'monospace',
                  letterSpacing: 2.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            onPressed: () => _joinJournal(
                context, ref, codeController.text.trim().toUpperCase()),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  // Private helper methods

  static Future<void> _copyToClipboard(
      BuildContext context, String code) async {
    try {
      await Clipboard.setData(ClipboardData(text: code));
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code copied to clipboard: $code'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code: $code'),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm)),
          ),
        );
      }
    }
  }

  static Future<void> _createJournal(
      BuildContext context, WidgetRef ref, String title, bool isShared) async {
    if (title.isNotEmpty) {
      try {
        await ref
            .read(journalsProvider.notifier)
            .createJournal(title, isShared);
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
    }
  }

  static Future<void> _joinJournal(
      BuildContext context, WidgetRef ref, String code) async {
    if (code.isNotEmpty) {
      try {
        await ref.read(journalsProvider.notifier).joinJournal(code);
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
    }
  }
}
