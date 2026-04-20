import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../models/goal.dart';
import 'package:uuid/uuid.dart';

class GoalForm extends StatefulWidget {
  final Goal? initialGoal;
  final Function(Goal) onSave;

  const GoalForm({super.key, this.initialGoal, required this.onSave});

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController frequencyController;
  late String selectedType;
  late DateTime? selectedEndDate;
  late bool isPublic;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialGoal?.title);
    descriptionController = TextEditingController(
      text: widget.initialGoal?.description,
    );
    frequencyController = TextEditingController(
      text: widget.initialGoal?.frequency,
    );
    selectedType = widget.initialGoal?.type ?? 'Goal';
    selectedEndDate = widget.initialGoal?.endDate;
    isPublic = widget.initialGoal?.isPublic ?? false;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    frequencyController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          selectedEndDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => selectedEndDate = picked);
    }
  }

  void _saveGoal() {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    final goal = Goal(
      goalId: widget.initialGoal?.goalId ?? const Uuid().v4(),
      title: titleController.text,
      description: descriptionController.text.isEmpty
          ? null
          : descriptionController.text,
      type: selectedType,
      frequency: frequencyController.text.isEmpty
          ? null
          : frequencyController.text,
      endDate: selectedEndDate,
      isPublic: isPublic,
      progress: widget.initialGoal?.progress ?? 0.0,
    );

    if (widget.initialGoal != null) {
      goal.id = widget.initialGoal!.id;
      goal.sessionsCompleted = widget.initialGoal!.sessionsCompleted;
      goal.totalMinutes = widget.initialGoal!.totalMinutes;
      goal.createdAt = widget.initialGoal!.createdAt;
    }

    widget.onSave(goal);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: AppStrings.goalTitle,
                hintText: 'Enter goal title',
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Description field
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: AppStrings.goalDescription,
                hintText: 'Enter description (optional)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.md),

            // Type selector
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              decoration: InputDecoration(labelText: AppStrings.goalType),
              items: const [
                DropdownMenuItem(value: 'Habit', child: Text('Habit')),
                DropdownMenuItem(value: 'Study', child: Text('Study')),
                DropdownMenuItem(value: 'Goal', child: Text('Goal')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedType = value);
                }
              },
            ),
            const SizedBox(height: AppSizes.md),

            // Frequency field
            TextField(
              controller: frequencyController,
              decoration: InputDecoration(
                labelText: AppStrings.goalFrequency,
                hintText: '2 times per week',
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // End date field
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                AppStrings.goalEndDate,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                selectedEndDate?.toString().split(' ')[0] ?? 'Not set',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: AppSizes.md),

            // Is public toggle
            CheckboxListTile(
              value: isPublic,
              onChanged: (value) {
                setState(() => isPublic = value ?? false);
              },
              title: Text(AppStrings.goalIsPublic),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSizes.lg),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveGoal,
                child: Text(
                  widget.initialGoal != null
                      ? AppStrings.editGoal
                      : AppStrings.saveGoal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
