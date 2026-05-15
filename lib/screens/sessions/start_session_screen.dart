import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/app_bar_custom.dart';
import '../../providers/goal_provider.dart';

class StartSessionScreen extends ConsumerWidget {
  const StartSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final activeSessionsAsync = ref.watch(activeSessionsProvider);

    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.startSession),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'No goals yet. Create one first!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return activeSessionsAsync.when(
            data: (activeSessions) {
              final activeGoalIds = activeSessions
                  .map((s) => s.goalId)
                  .toSet();

              return ListView.builder(
                padding: const EdgeInsets.all(AppSizes.md),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final hasActiveSession = activeGoalIds.contains(goal.goalId);

                  return Card(
                    child: ListTile(
                      title: Text(goal.title),
                      subtitle: Text(
                        hasActiveSession
                            ? '${goal.type} • Session running'
                            : goal.type,
                      ),
                      trailing: hasActiveSession
                          ? const Chip(
                              label: Text('Active'),
                              avatar: Icon(Icons.play_arrow, size: 16),
                              visualDensity: VisualDensity.compact,
                            )
                          : const Icon(Icons.arrow_forward),
                      onTap: () {
                        final goalId = goal.goalId.trim();
                        if (goalId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Unable to start session for this goal',
                              ),
                            ),
                          );
                          return;
                        }

                        context.pushNamed(
                          'activeSession',
                          pathParameters: {'goalId': goalId},
                        );
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
