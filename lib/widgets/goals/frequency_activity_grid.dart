import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/frequency_utils.dart';
import '../../models/session.dart';

class FrequencyActivityGrid extends StatelessWidget {
  final String frequency;
  final DateTime anchorDate;
  final List<Session> sessions;

  const FrequencyActivityGrid({
    super.key,
    required this.frequency,
    required this.anchorDate,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final schedule = FrequencyUtils.parse(frequency);
    if (schedule == null) {
      return const Text('No frequency schedule found.');
    }

    final completedDays = sessions
        .where((s) => s.status == 'Completed')
        .map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day))
        .toSet();

    final today = DateTime.now();
    final days = List.generate(56, (index) {
      final day = today.subtract(Duration(days: 55 - index));
      return DateTime(day.year, day.month, day.day);
    });

    final weeks = <List<DateTime>>[];
    for (var i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, i + 7));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency Activity',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSizes.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: weeks.map((week) {
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Column(
                  children: week.map((day) {
                    final expected = FrequencyUtils.isExpectedOnDate(
                      schedule: schedule,
                      date: day,
                      anchor: anchorDate,
                    );
                    final completed = completedDays.contains(day);

                    Color fill;
                    if (expected && completed) {
                      fill = AppColors.primary;
                    } else if (expected) {
                      fill = AppColors.outline;
                    } else {
                      fill = Theme.of(context).colorScheme.surfaceContainerHighest;
                    }

                    return Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(bottom: 3),
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Row(
          children: [
            _Legend(color: AppColors.primary, label: 'Done'),
            const SizedBox(width: AppSizes.md),
            _Legend(color: AppColors.outline, label: 'Missed'),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
