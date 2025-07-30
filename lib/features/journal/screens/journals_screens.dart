import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journalee/features/auth/providers/auth_providers.dart';
import 'package:journalee/features/journal/providers/journal_providers.dart';
import 'package:journalee/features/journal/widgets/floating_action_button.dart';
import 'package:journalee/features/journal/widgets/journal_widgets.dart';
import '../../../core/theme/app_theme.dart';

class JournalsScreen extends ConsumerWidget {
  const JournalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalsAsync = ref.watch(journalsProvider);
    final user = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Journalee',
          style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () => ref.read(journalsProvider.notifier).refresh(),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () => _showSignOutDialog(context, ref),
            tooltip: 'Sign Out',
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: journalsAsync.when(
        data: (journals) => journals.isEmpty
            ? const EmptyJournalsState()
            : JournalsCarousel(
                journals: journals,
                currentUserId: user?.id ?? '',
                onDeleteJournal: (journalId) =>
                    _handleDeleteJournal(context, ref, journalId),
                onLeaveJournal: (journalId) =>
                    _handleLeaveJournal(context, ref, journalId),
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, stack) => ErrorState(
          onRetry: () => ref.read(journalsProvider.notifier).refresh(),
        ),
      ),
      floatingActionButton: const FloatingActionButtons(),
    );
  }

  Future<void> _handleDeleteJournal(
      BuildContext context, WidgetRef ref, String journalId) async {
    try {
      await ref.read(journalsProvider.notifier).deleteJournal(journalId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Journal deleted successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting journal: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleLeaveJournal(
      BuildContext context, WidgetRef ref, String journalId) async {
    try {
      await ref.read(journalsProvider.notifier).leaveJournal(journalId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Left journal successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error leaving journal: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        );
      }
    }
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        title: Text('Sign Out', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to sign out?',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
