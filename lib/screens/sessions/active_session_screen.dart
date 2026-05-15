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
  Session? _currentSession;
  bool _isSaving = false;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _seconds = 0;
    _isRunning = false;
    _currentSession = null;
    _notesController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActiveSession();
    });
  }

  Future<void> _loadActiveSession() async {
    try {
      final sessionRepository = await ref.read(
        sessionRepositoryProvider.future,
      );
      final session = await sessionRepository.getActiveSessionForGoal(
        widget.goalId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _currentSession = session;
        if (session != null) {
          _seconds = DateTime.now().difference(session.startTime).inSeconds;
          _isRunning = session.status == 'Active';
          if (session.notes != null && session.notes!.trim().isNotEmpty) {
            _notesController.text = session.notes!;
          }
        }
      });
      if (_isRunning) {
        _tickTimer();
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    if (_isSaving) {
      return;
    }

    if (_currentSession == null) {
      final newSession = Session(
        sessionId: const Uuid().v4(),
        goalId: widget.goalId,
        status: 'Active',
      );

      try {
        await ref.read(createSessionProvider.notifier).createSession(newSession);
        if (!mounted) {
          return;
        }
        setState(() {
          _currentSession = newSession;
          _seconds = 0;
          _isRunning = true;
        });
      } catch (e) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting session: $e')),
        );
        return;
      }
    } else {
      try {
        await ref
            .read(createSessionProvider.notifier)
            .resumeSession(_currentSession!.sessionId);
        if (!mounted) {
          return;
        }
        setState(() => _isRunning = true);
      } catch (e) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resuming session: $e')),
        );
        return;
      }
    }

    _tickTimer();
  }

  Future<void> _pauseSession() async {
    if (_currentSession == null || _isSaving) {
      return;
    }

    try {
      await ref
          .read(createSessionProvider.notifier)
          .pauseSession(_currentSession!.sessionId);
      if (!mounted) {
        return;
      }
      setState(() => _isRunning = false);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error pausing session: $e')));
    }
  }

  Future<void> _resumeSession() async {
    if (_currentSession == null || _isSaving) {
      return;
    }

    try {
      await ref
          .read(createSessionProvider.notifier)
          .resumeSession(_currentSession!.sessionId);
      if (!mounted) {
        return;
      }
      setState(() => _isRunning = true);
      _tickTimer();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error resuming session: $e')));
    }
  }

  void _tickTimer() {
    if (_isRunning) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _isRunning) {
          setState(() => _seconds++);
          _tickTimer();
        }
      });
    }
  }

  Future<void> _endSession() async {
    if (_isSaving || _currentSession == null) {
      return;
    }

    setState(() {
      _isRunning = false;
      _isSaving = true;
    });

    try {
      _currentSession!
        ..notes = _notesController.text
        ..durationMinutes = _seconds ~/ 60;
      final repository = await ref.read(sessionRepositoryProvider.future);
      await repository.updateSession(_currentSession!);

      await ref
          .read(createSessionProvider.notifier)
          .completeSession(_currentSession!.sessionId, widget.goalId);

      if (!mounted) {
        return;
      }

      final goal = await ref.read(goalProvider(widget.goalId).future);
      final canEditProgress =
          goal != null && goal.type == 'Goal' && goal.endDate == null;

      if (canEditProgress) {
        final progress = await _showProgressUpdateDialog(goal.progress);
        if (progress != null) {
          final goalRepo = await ref.read(goalRepositoryProvider.future);
          await goalRepo.updateGoalProgress(widget.goalId, progress);
          ref.invalidate(goalsProvider);
          ref.invalidate(goalProvider(widget.goalId));
        }
      }

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Session completed! Duration: ${_seconds ~/ 60} minutes',
          ),
        ),
      );
      context.goNamed('goals');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving session: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<double?> _showProgressUpdateDialog(double currentProgress) async {
    if (!mounted) {
      return null;
    }

    double selected = currentProgress;
    return showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Update Goal Progress'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${selected.toStringAsFixed(0)}% complete'),
                  Slider(
                    value: selected,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '${selected.toStringAsFixed(0)}%',
                    onChanged: (value) {
                      setDialogState(() => selected = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Skip'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(selected),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
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
