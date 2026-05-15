import 'package:flutter/material.dart';
import 'package:productive_peers/models/milestone.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 100.0
  final String label;
  final Color? backgroundColor;
  final Color? progressColor;
  final List<Milestone>? milestones;

  const ProgressBar({
    super.key,
    required this.progress,
    this.label = 'Progress',
    this.backgroundColor,
    this.progressColor,
    this.milestones,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 100.0) / 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '${progress.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              child: LinearProgressIndicator(
                value: clampedProgress,
                minHeight: 8,
                backgroundColor: backgroundColor ?? AppColors.outline,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressColor ?? AppColors.primary,
                ),
              ),
            ),
            if (milestones != null)
              LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: milestones!.map((milestone) {
                      final left = constraints.maxWidth * (milestone.percentage! / 100);
                      return Positioned(
                        left: left,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 2,
                          color: milestone.isCompleted ? Colors.white : Colors.grey,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}
