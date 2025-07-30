import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journalee/features/journal/widgets/journal_card.dart';
import '../models/journal_model.dart';
import '../../../../core/theme/app_theme.dart';
import 'journal_dialogs.dart';

// Empty state widget when no journals exist
class EmptyJournalsState extends ConsumerWidget {
  const EmptyJournalsState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Icon(
                Icons.book_outlined,
                size: 80,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Welcome to Journalee',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your personal space for thoughts, ideas, and memories',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildGettingStartedCard(),
            const SizedBox(height: AppSpacing.xl),
            _buildQuickActions(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildGettingStartedCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Getting Started',
            style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStepItem(
              '1',
              'Create your first journal',
              'Tap the + button below to start writing',
              Icons.add_circle_outline),
          const SizedBox(height: AppSpacing.md),
          _buildStepItem(
              '2',
              'Share with others (optional)',
              'Make it shared and invite friends with a code',
              Icons.share_outlined),
          const SizedBox(height: AppSpacing.md),
          _buildStepItem(
              '3',
              'Start journaling',
              'Write your thoughts with rich text formatting',
              Icons.edit_outlined),
        ],
      ),
    );
  }

  Widget _buildStepItem(
      String number, String title, String description, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
              Text(description,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => JournalDialogs.showCreateDialog(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(AppSpacing.md),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Create Journal'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => JournalDialogs.showJoinDialog(context, ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent),
              padding: const EdgeInsets.all(AppSpacing.md),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            icon: const Icon(Icons.group_add),
            label: const Text('Join Journal'),
          ),
        ),
      ],
    );
  }
}

// Journals carousel widget for displaying journals
class JournalsCarousel extends StatelessWidget {
  final List<JournalModel> journals;
  final String currentUserId;
  final Function(String journalId)? onDeleteJournal;
  final Function(String journalId)? onLeaveJournal;

  const JournalsCarousel({
    super.key,
    required this.journals,
    required this.currentUserId,
    this.onDeleteJournal,
    this.onLeaveJournal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(
          '${journals.length} ${journals.length == 1 ? 'Journal' : 'Journals'}',
          style:
              AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.85),
            itemCount: journals.length,
            itemBuilder: (context, index) {
              final journal = journals[index];
              final isOwner = journal.isOwnedBy(currentUserId);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: JournalCard(
                  journal: journal,
                  isOwner: isOwner,
                  onDelete: onDeleteJournal != null && isOwner
                      ? () => onDeleteJournal!(journal.id)
                      : null,
                  onLeave: onLeaveJournal != null && !isOwner
                      ? () => onLeaveJournal!(journal.id)
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swipe, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Swipe to explore journals',
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

// Error state widget
class ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Something went wrong',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
