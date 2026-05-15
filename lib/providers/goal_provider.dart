import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../models/goal.dart';
import '../../models/session.dart';
import '../../models/user.dart';

// Isar instances provider
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open([
    GoalSchema,
    SessionSchema,
    UserSchema,
  ], directory: dir.path);
});

// Repository providers
final goalRepositoryProvider = FutureProvider<GoalRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return GoalRepository(isar);
});

final sessionRepositoryProvider = FutureProvider<SessionRepository>((
  ref,
) async {
  final isar = await ref.watch(isarProvider.future);
  return SessionRepository(isar);
});

// Goals list provider
final goalsProvider = FutureProvider<List<Goal>>((ref) async {
  final repository = await ref.watch(goalRepositoryProvider.future);
  return repository.getAllGoals();
});

// Goals by type provider (Family)
final goalsByTypeProvider = FutureProvider.family<List<Goal>, String>((
  ref,
  type,
) async {
  final repository = await ref.watch(goalRepositoryProvider.future);
  return repository.getGoalsByType(type);
});

// Single goal provider (Family)
final goalProvider = FutureProvider.family<Goal?, String>((ref, goalId) async {
  final repository = await ref.watch(goalRepositoryProvider.future);
  return repository.getGoalById(goalId);
});

// Sessions list provider
final sessionsProvider = FutureProvider<List<Session>>((ref) async {
  final repository = await ref.watch(sessionRepositoryProvider.future);
  return repository.getAllSessions();
});

// Sessions by goal provider (Family)
final sessionsByGoalProvider = FutureProvider.family<List<Session>, String>((
  ref,
  goalId,
) async {
  final repository = await ref.watch(sessionRepositoryProvider.future);
  return repository.getSessionsByGoalId(goalId);
});

// Active sessions provider
final activeSessionsProvider = FutureProvider<List<Session>>((ref) async {
  final repository = await ref.watch(sessionRepositoryProvider.future);
  return repository.getActiveSessions();
});

// Active session for goal provider (Family)
final activeSessionForGoalProvider = FutureProvider.family<Session?, String>((
  ref,
  goalId,
) async {
  final repository = await ref.watch(sessionRepositoryProvider.future);
  return repository.getActiveSessionForGoal(goalId);
});

// Create/Update goal notifier
class CreateGoalNotifier extends StateNotifier<AsyncValue<void>> {
  CreateGoalNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> createGoal(Goal goal) async {
    state = const AsyncValue.loading();
    try {
      final repository = await ref.read(goalRepositoryProvider.future);
      await repository.createGoal(goal);
      // Invalidate the goals list to refresh
      ref.invalidate(goalsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateGoal(Goal goal) async {
    state = const AsyncValue.loading();
    try {
      final repository = await ref.read(goalRepositoryProvider.future);
      await repository.updateGoal(goal);
      // Invalidate related providers
      ref.invalidate(goalsProvider);
      ref.invalidate(goalProvider(goal.goalId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteGoal(String goalId) async {
    state = const AsyncValue.loading();
    try {
      final repository = await ref.read(goalRepositoryProvider.future);
      await repository.deleteGoal(goalId);
      // Invalidate related providers
      ref.invalidate(goalsProvider);
      ref.invalidate(goalProvider(goalId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final createGoalProvider =
    StateNotifierProvider<CreateGoalNotifier, AsyncValue<void>>((ref) {
      return CreateGoalNotifier(ref);
    });

// Create/Update session notifier
class CreateSessionNotifier extends StateNotifier<AsyncValue<void>> {
  CreateSessionNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> createSession(Session session) async {
    state = const AsyncValue.loading();
    try {
      final repository = await ref.read(sessionRepositoryProvider.future);
      await repository.createSession(session);
      // Invalidate related providers
      ref.invalidate(sessionsProvider);
      ref.invalidate(sessionsByGoalProvider(session.goalId));
      ref.invalidate(activeSessionsProvider);
      ref.invalidate(activeSessionForGoalProvider(session.goalId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeSession(String sessionId, String goalId) async {
    state = const AsyncValue.loading();
    try {
      final repository = await ref.read(sessionRepositoryProvider.future);
      await repository.completeSession(sessionId);
      // Update goal statistics
      final goalRepo = await ref.read(goalRepositoryProvider.future);
      await goalRepo.incrementSessionsCompleted(goalId);
      final session = await repository.getSessionById(sessionId);
      if (session != null) {
        await goalRepo.addMinutes(goalId, session.durationMinutes);
      }
      // Invalidate related providers
      ref.invalidate(sessionsProvider);
      ref.invalidate(sessionsByGoalProvider(goalId));
      ref.invalidate(activeSessionsProvider);
      ref.invalidate(activeSessionForGoalProvider(goalId));
      ref.invalidate(goalsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pauseSession(String sessionId) async {
    state = const AsyncValue.loading();
    try {
      final repository = await ref.read(sessionRepositoryProvider.future);
      await repository.pauseSession(sessionId);
      final session = await repository.getSessionById(sessionId);
      ref.invalidate(sessionsProvider);
      ref.invalidate(activeSessionsProvider);
      if (session != null) {
        ref.invalidate(sessionsByGoalProvider(session.goalId));
        ref.invalidate(activeSessionForGoalProvider(session.goalId));
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resumeSession(String sessionId) async {
    state = const AsyncValue.loading();
    try {
      final repository = await ref.read(sessionRepositoryProvider.future);
      await repository.resumeSession(sessionId);
      final session = await repository.getSessionById(sessionId);
      ref.invalidate(sessionsProvider);
      ref.invalidate(activeSessionsProvider);
      if (session != null) {
        ref.invalidate(sessionsByGoalProvider(session.goalId));
        ref.invalidate(activeSessionForGoalProvider(session.goalId));
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final createSessionProvider =
    StateNotifierProvider<CreateSessionNotifier, AsyncValue<void>>((ref) {
      return CreateSessionNotifier(ref);
    });
