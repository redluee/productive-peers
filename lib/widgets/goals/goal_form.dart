import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../models/goal.dart';

class GoalForm extends StatefulWidget {
  final Goal? initialGoal;
  final Function(Goal) onSave;

  const GoalForm({super.key, this.initialGoal, required this.onSave});

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();
  late String _type;

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetPercentageController;

  // Habit
  String _frequencyUnit = 'week'; // day, week, month
  int _frequencyValue = 2;
  Set<String> _selectedWeekdays = {'Monday'};

  // Study
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _type = widget.initialGoal!.type;

    _titleController = TextEditingController(text: widget.initialGoal?.title);
    _descriptionController = TextEditingController(text: widget.initialGoal?.description);
    _targetPercentageController = TextEditingController(
      text: widget.initialGoal?.targetPercentage.toStringAsFixed(0) ?? '100',
    );

    _startDate = widget.initialGoal?.startDate ?? DateTime.now();
    _endDate = widget.initialGoal?.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetPercentageController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final goal = Goal(
      goalId: widget.initialGoal?.goalId ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      type: _type,
      // Habit specific
      frequency: _type == 'Habit' ? '$_frequencyValue times/$_frequencyUnit' : null,
      frequencyDays: _type == 'Habit' ? _selectedWeekdays.toList() : null,
      // Goal specific
      targetPercentage: _type == 'Goal'
          ? double.tryParse(_targetPercentageController.text) ?? 100.0
          : 100.0,
      // Study specific
      startDate: _type == 'Study' ? _startDate : null,
      endDate: _endDate,
    );

    if (widget.initialGoal != null && widget.initialGoal!.title.isNotEmpty) {
      goal.id = widget.initialGoal!.id;
    }

    widget.onSave(goal);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Create New $_type', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSizes.lg),
            _buildTitleField(),
            const SizedBox(height: AppSizes.md),
            _buildDescriptionField(),
            const SizedBox(height: AppSizes.lg),
            if (_type == 'Habit') _buildHabitFields(),
            if (_type == 'Goal') _buildGoalFields(),
            if (_type == 'Study') _buildStudyFields(),
            const SizedBox(height: AppSizes.lg),
            ElevatedButton(
              onPressed: _saveForm,
              child: const Text('Save Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: AppStrings.goalTitle,
        hintText: 'e.g., Learn Flutter',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title.';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: AppStrings.goalDescription,
        hintText: 'Add more details (optional)',
      ),
      maxLines: 3,
    );
  }

  Widget _buildHabitFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequency', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: _frequencyValue.toString(),
                decoration: const InputDecoration(labelText: 'Times'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _frequencyValue = int.tryParse(value ?? '2') ?? 2,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                value: _frequencyUnit,
                decoration: const InputDecoration(labelText: 'Per'),
                items: const [
                  DropdownMenuItem(value: 'day', child: Text('Day')),
                  DropdownMenuItem(value: 'week', child: Text('Week')),
                  DropdownMenuItem(value: 'month', child: Text('Month')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _frequencyUnit = value);
                  }
                },
              ),
            ),
          ],
        ),
        if (_frequencyUnit == 'week') ...[
          const SizedBox(height: AppSizes.md),
          Text('On these days', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            children: DateFormat().dateSymbols.WEEKDAYS.map((day) {
              return FilterChip(
                label: Text(day.substring(0, 3)),
                selected: _selectedWeekdays.contains(day),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedWeekdays.add(day);
                    } else {
                      _selectedWeekdays.remove(day);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: AppSizes.md),
        _buildDateField('End Date (Optional)', _endDate, (date) => setState(() => _endDate = date)),
      ],
    );
  }

  Widget _buildGoalFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _targetPercentageController,
          decoration: const InputDecoration(
            labelText: 'Target Percentage',
            suffixText: '%',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            final num? val = num.tryParse(value ?? '');
            if (val == null || val <= 0 || val > 100) {
              return 'Enter a value between 1 and 100.';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.md),
        _buildDateField('End Date (Optional)', _endDate, (date) => setState(() => _endDate = date)),
      ],
    );
  }

  Widget _buildStudyFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateField('Start Date', _startDate, (date) => setState(() => _startDate = date)),
        const SizedBox(height: AppSizes.md),
        _buildDateField('End Date (Optional)', _endDate, (date) => setState(() => _endDate = date)),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onSelect) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(date != null ? DateFormat.yMMMd().format(date) : 'Not set'),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        if (picked != null) {
          onSelect(picked);
        }
      },
    );
  }
}
