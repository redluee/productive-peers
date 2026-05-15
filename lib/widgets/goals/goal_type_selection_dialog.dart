import 'package:flutter/material.dart';
import 'package:productive_peers/core/constants/app_sizes.dart';

class GoalTypeSelectionDialog extends StatelessWidget {
  const GoalTypeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            context,
            icon: Icons.bolt_rounded,
            title: 'Habit',
            subtitle: 'Track daily streaks and build consistency.',
            type: 'Habit',
            color: const Color(0xFF9C27B0),
          ),
          const SizedBox(height: AppSizes.md),
          _buildOption(
            context,
            icon: Icons.flag_rounded,
            title: 'Goal',
            subtitle: 'Define milestones and track percentage-based progress.',
            type: 'Goal',
            color: const Color(0xFFFF9800),
          ),
          const SizedBox(height: AppSizes.md),
          _buildOption(
            context,
            icon: Icons.school_rounded,
            title: 'Study',
            subtitle: 'Set a schedule with date-based milestones.',
            type: 'Study',
            color: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String type,
    required Color color,
  }) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(type),
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: AppSizes.iconLg),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSizes.sm),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
