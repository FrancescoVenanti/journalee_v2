// Floating action buttons widget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journalee/core/theme/app_theme.dart';
import 'package:journalee/features/journal/widgets/journal_dialogs.dart';

class FloatingActionButtons extends ConsumerWidget {
  const FloatingActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.medium,
            border: Border.all(
              color: AppColors.accent,
              width: 2,
            ),
          ),
          child: FloatingActionButton.extended(
            heroTag: 'join',
            onPressed: () => JournalDialogs.showJoinDialog(context, ref),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.accent,
            elevation: 0,
            label: const Text('Join'),
            icon: const Icon(Icons.group_add, size: 24),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.medium,
          ),
          child: FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: () => JournalDialogs.showCreateDialog(context, ref),
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            label: const Text('New'),
            icon: const Icon(Icons.add, size: 24),
          ),
        ),
      ],
    );
  }
}
