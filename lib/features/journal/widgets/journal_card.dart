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
  final VoidCallback? onDelete;
  final VoidCallback? onLeave;

  const JournalCard({
    super.key,
    required this.journal,
    required this.isOwner,
    this.onDelete,
    this.onLeave,
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
          onLongPress: () => _showJournalOptions(context),
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

  void _showJournalOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isOwner
                        ? AppColors.accentSoft
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    isOwner ? Icons.book : Icons.group,
                    color: isOwner ? AppColors.accent : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        journal.displayTitle,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (journal.isShared)
                        Text(
                          'Code: ${journal.code}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontFamily: 'monospace',
                            letterSpacing: 1.0,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Options
            if (isOwner)
              _buildOptionTile(
                context,
                icon: Icons.delete_outline,
                title: 'Delete Journal',
                subtitle: 'Permanently delete this journal and all entries',
                color: AppColors.error,
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmation(context);
                },
              )
            else
              _buildOptionTile(
                context,
                icon: Icons.exit_to_app,
                title: 'Leave Journal',
                subtitle: 'Stop viewing this shared journal',
                color: AppColors.warning,
                onTap: () {
                  Navigator.of(context).pop();
                  _showLeaveConfirmation(context);
                },
              ),

            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_outlined,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Delete Journal',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${journal.displayTitle}"?',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This will permanently delete the journal and all its entries. This action cannot be undone.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
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
            onPressed: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLeaveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        title: Row(
          children: [
            Icon(
              Icons.exit_to_app,
              color: AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Leave Journal',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to leave "${journal.displayTitle}"?',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You can rejoin this journal later using the code: ${journal.code}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
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
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onLeave?.call();
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
