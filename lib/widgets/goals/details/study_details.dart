import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productive_peers/models/goal.dart';
import 'package:timeline_tile/timeline_tile.dart';

class StudyDetails extends StatefulWidget {
  final Goal goal;
  final Function(Goal) onUpdate;

  const StudyDetails({super.key, required this.goal, required this.onUpdate});

  @override
  State<StudyDetails> createState() => _StudyDetailsState();
}

class _StudyDetailsState extends State<StudyDetails> {
  @override
  Widget build(BuildContext context) {
    // Sort milestones by date
    widget.goal.milestones.sort((a, b) => a.targetDate!.compareTo(b.targetDate!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Timeline', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        if (widget.goal.milestones.isEmpty)
          const Text('No milestones yet. Add one to get started!'),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.goal.milestones.length,
          itemBuilder: (context, index) {
            final milestone = widget.goal.milestones[index];
            return TimelineTile(
              alignment: TimelineAlign.manual,
              lineXY: 0.1,
              isFirst: index == 0,
              isLast: index == widget.goal.milestones.length - 1,
              indicatorStyle: IndicatorStyle(
                width: 20,
                color: milestone.isCompleted ? Colors.green : Colors.grey,
                iconStyle: IconStyle(
                  iconData: milestone.isCompleted ? Icons.check : Icons.circle,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              endChild: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            milestone.description ?? '',
                            style: TextStyle(
                              decoration: milestone.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          Text(
                            DateFormat.yMMMd().format(milestone.targetDate!),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: milestone.isCompleted,
                      onChanged: (bool? value) {
                        setState(() {
                          milestone.isCompleted = value ?? false;
                          widget.onUpdate(widget.goal);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
