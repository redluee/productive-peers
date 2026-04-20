import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';

class SessionTimer extends StatelessWidget {
  final int seconds;
  final VoidCallback? onStartPressed;
  final VoidCallback? onPausePressed;
  final VoidCallback? onResumePressed;
  final VoidCallback? onEndPressed;
  final bool isRunning;

  const SessionTimer({
    super.key,
    required this.seconds,
    this.onStartPressed,
    this.onPausePressed,
    this.onResumePressed,
    this.onEndPressed,
    this.isRunning = false,
  });

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _formatTime(seconds),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontFamily: 'monospace',
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isRunning && seconds == 0)
              ElevatedButton.icon(
                onPressed: onStartPressed,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
              )
            else if (isRunning)
              ElevatedButton.icon(
                onPressed: onPausePressed,
                icon: const Icon(Icons.pause),
                label: const Text('Pause'),
              )
            else
              ElevatedButton.icon(
                onPressed: onResumePressed,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Resume'),
              ),
            const SizedBox(width: AppSizes.md),
            OutlinedButton.icon(
              onPressed: onEndPressed,
              icon: const Icon(Icons.stop),
              label: const Text('End'),
            ),
          ],
        ),
      ],
    );
  }
}
