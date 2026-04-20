import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 100.0
  final String label;
  final Color? backgroundColor;
  final Color? progressColor;

  const ProgressBar({
    super.key,
    required this.progress,
    required this.label,
    this.backgroundColor,
    this.progressColor,
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
      ],
    );
  }
}
