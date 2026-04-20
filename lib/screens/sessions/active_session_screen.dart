import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../models/session.dart';
import '../../providers/goal_provider.dart';
import '../../widgets/common/app_bar_custom.dart';
import '../../widgets/sessions/session_timer.dart';

class ActiveSessionScreen extends ConsumerStatefulWidget {
  final String goalId;

  const ActiveSessionScreen({super.key, required this.goalId});

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  late int _seconds;
  late bool _isRunning;
  late Session? _currentSession;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _seconds = 0;
    _isRunning = false;
    _notesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadActiveSession();
  }

  Future<void> _loadActiveSession() async {
    try {
      final sessionRepository = await ref.read(
        sessionRepositoryProvider.future,
      );
      final session = await sessionRepository.getActiveSessionForGoal(
        widget.goalId,
      );
      setState(() => _currentSession = session);
    } catch (e) {
      // ignore
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _startSession() {
    setState(() => _isRunning = true);
    _tickTimer();
  }

  void _pauseSession() {
    setState(() => _isRunning = false);
  }

  void _resumeSession() {
    setState(() => _isRunning = true);
    _tickTimer();
  }

  void _tickTimer() {
    if (_isRunning) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _seconds++);
          _tickTimer();
        }
      });
    }
  }

  Future<void> _endSession() async {
    if (_currentSession == null) {
      // Create new session if not exists
      _currentSession = Session(
        sessionId: const Uuid().v4(),
        goalId: widget.goalId,
        status: 'Completed',
      );
      _currentSession!.endTime = DateTime.now();
      _currentSession!.durationMinutes = _seconds ~/ 60;
      _currentSession!.notes = _notesController.text;

      try {
        await ref
            .read(createSessionProvider.notifier)
            .createSession(_currentSession!);
        // Complete it to update stats
        await ref
            .read(createSessionProvider.notifier)
            .completeSession(_currentSession!.sessionId, widget.goalId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Session completed! Duration: ${_seconds ~/ 60} minutes',
              ),
            ),
          );
          context.go('/');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving session: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.activeSession),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SessionTimer(
              seconds: _seconds,
              isRunning: _isRunning,
              onStartPressed: _startSession,
              onPausePressed: _pauseSession,
              onResumePressed: _resumeSession,
              onEndPressed: _endSession,
            ),
            const SizedBox(height: AppSizes.xl),
            Text(
              AppStrings.sessionNotes,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Add notes about your session...',
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
