import 'package:flutter/material.dart';
import 'package:productive_peers/models/goal.dart';
import 'package:productive_peers/widgets/goals/progress_bar.dart';

class GoalDetails extends StatefulWidget {
  final Goal goal;
  final Function(Goal) onUpdate;

  const GoalDetails({super.key, required this.goal, required this.onUpdate});

  @override
  State<GoalDetails> createState() => _GoalDetailsState();
}

class _GoalDetailsState extends State<GoalDetails> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProgressBar(
          progress: widget.goal.progress,
          milestones: widget.goal.milestones,
        ),
        const SizedBox(height: 24),
        Text('Milestones', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (widget.goal.milestones.isEmpty)
          const Text('No milestones yet. Add one to get started!'),
        ...widget.goal.milestones.map((milestone) {
          return CheckboxListTile(
            value: milestone.isCompleted,
            title: Text(milestone.description ?? ''),
            subtitle: Text('${milestone.percentage?.toStringAsFixed(0) ?? ''}%'),
            onChanged: (bool? value) {
              setState(() {
                milestone.isCompleted = value ?? false;
                // Update overall progress
                if (milestone.isCompleted) {
                  widget.goal.progress = milestone.percentage ?? widget.goal.progress;
                } else {
                  // Find the previous completed milestone to set the progress
                  final completedMilestones = widget.goal.milestones
                      .where((m) => m.isCompleted)
                      .toList();
                  if (completedMilestones.isEmpty) {
                    widget.goal.progress = 0;
                  } else {
                    completedMilestones.sort((a, b) => a.percentage!.compareTo(b.percentage!));
                    widget.goal.progress = completedMilestones.last.percentage!;
                  }
                }
                widget.onUpdate(widget.goal);
              });
            },
          );
        }),
      ],
    );
  }
}
