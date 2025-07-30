// Individual journal card widget
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journalee/core/theme/app_theme.dart';
import 'package:journalee/features/journal/models/journal_model.dart';
import 'package:journalee/features/journal/widgets/journal_dialogs.dart';

class JournalCard extends StatelessWidget {
  final JournalModel journal;
  final bool isOwner;

  const JournalCard({
    super.key,
    required this.journal,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    // final daysSinceCreated =
    //     DateTime.now().difference(journal.createdAt).inDays;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: AppShadows.large,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: () => context.go('/entries/${journal.id}'),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.xl),
                _buildTitle(),
                const SizedBox(height: AppSpacing.lg),
                _buildStats(journal.createdAt),
                const Spacer(),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Owner badge (left)
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isOwner ? AppColors.accentSoft : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: isOwner ? AppColors.accent : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                isOwner ? 'Owner' : 'Member',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isOwner ? AppColors.accent : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Share button (right)
        if (journal.isShared) _buildShareButton(),
      ],
    );
  }

  Widget _buildShareButton() {
    return Builder(
      builder: (context) => Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: () => JournalDialogs.showShareCode(context, journal),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.share, size: 16, color: AppColors.accent),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Share',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        journal.displayTitle,
        style: AppTextStyles.heading2.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStats(DateTime date) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatItem(
            'Created',
            DateFormat('dd/MM/yy').format(journal.createdAt),
            Icons.calendar_today,
          ),
          const SizedBox(width: 1, height: 40),
          _buildStatItem(
            'Type',
            journal.isShared ? 'Shared' : 'Private',
            journal.isShared ? Icons.share : Icons.lock,
          ),
          const SizedBox(width: 1, height: 40),
          _buildStatItem(
            'Last Updated',
            _formatLastUpdated(journal.createdAt),
            Icons.edit,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(height: AppSpacing.xs),
        Text(label,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatLastUpdated(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return difference.inDays == 1 ? '1d ago' : '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? '1h ago' : '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1m ago'
          : '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
