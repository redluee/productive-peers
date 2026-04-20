import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/goal.dart';
import 'progress_bar.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
    this.onLongPress,
  });

  Color _getTypeColor() {
    switch (goal.type) {
      case 'Habit':
        return const Color(0xFF9C27B0); // Purple
      case 'Study':
        return const Color(0xFF2196F3); // Blue
      case 'Goal':
        return const Color(0xFFFF9800); // Orange
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon() {
    switch (goal.type) {
      case 'Habit':
        return Icons.bolt_rounded;
      case 'Study':
        return Icons.school;
      case 'Goal':
        return Icons.flag;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getTypeColor().withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Center(
                      child: Icon(
                        _getTypeIcon(),
                        size: AppSizes.iconMd,
                        color: _getTypeColor(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (goal.frequency != null)
                          Text(
                            goal.frequency!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  if (goal.isPublic)
                    Icon(
                      Icons.public,
                      size: AppSizes.iconSm,
                      color: AppColors.onSurfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              ProgressBar(
                progress: goal.progress,
                label: 'Progress',
                progressColor: _getTypeColor(),
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${goal.sessionsCompleted} sessions • ${goal.totalMinutes}m',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
