import 'package:flutter/material.dart';
import 'package:productive_peers/models/goal.dart';

class HabitDetails extends StatefulWidget {
  final Goal goal;
  final Function(Goal) onUpdate;

  const HabitDetails({super.key, required this.goal, required this.onUpdate});

  @override
  State<HabitDetails> createState() => _HabitDetailsState();
}

class _HabitDetailsState extends State<HabitDetails> {
  void _completeHabit() {
    // For simplicity, we assume completing it once a day is enough.
    // A more complex implementation would check frequency.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Avoid duplicates
    if (widget.goal.completions.any((c) => DateTime(c.year, c.month, c.day) == today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit already completed today!')),
      );
      return;
    }

    setState(() {
      widget.goal.completions.add(today);
      // Simple streak logic: check if yesterday was completed.
      final yesterday = today.subtract(const Duration(days: 1));
      if (widget.goal.completions.any((c) => c == yesterday)) {
        widget.goal.streak++;
      } else {
        widget.goal.streak = 1;
      }
      widget.onUpdate(widget.goal);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isCompletedToday = widget.goal.completions.any((c) => DateTime(c.year, c.month, c.day) == today);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('🔥', style: TextStyle(fontSize: 48)),
                Text('${widget.goal.streak} Day Streak', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            Column(
              children: [
                Text('✅', style: TextStyle(fontSize: 48)),
                Text('${widget.goal.completions.length} Total', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: isCompletedToday ? null : _completeHabit,
          child: Text(isCompletedToday ? 'Completed Today' : 'Mark as Done'),
        ),
        // TODO: Add a calendar heatmap view
      ],
    );
  }
}
