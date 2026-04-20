import 'package:isar/isar.dart';
import '../../models/session.dart';

class SessionRepository {
  final Isar isar;

  SessionRepository(this.isar);

  // Create a new session
  Future<Session> createSession(Session session) async {
    await isar.writeTxn(() async {
      await isar.sessions.put(session);
    });
    return session;
  }

  // Get all sessions
  Future<List<Session>> getAllSessions() async {
    return await isar.sessions.where().findAll();
  }

  // Get session by ID
  Future<Session?> getSessionById(String sessionId) async {
    final sessions = await isar.sessions.where().findAll();
    try {
      return sessions.firstWhere((s) => s.sessionId == sessionId);
    } catch (e) {
      return null;
    }
  }

  // Get sessions by goal ID
  Future<List<Session>> getSessionsByGoalId(String goalId) async {
    final sessions = await isar.sessions.where().findAll();
    return sessions.where((s) => s.goalId == goalId).toList();
  }

  // Get active sessions
  Future<List<Session>> getActiveSessions() async {
    final sessions = await isar.sessions.where().findAll();
    return sessions.where((s) => s.status == 'Active').toList();
  }

  // Get active session for a goal
  Future<Session?> getActiveSessionForGoal(String goalId) async {
    final sessions = await isar.sessions.where().findAll();
    try {
      return sessions.firstWhere(
        (s) => s.goalId == goalId && s.status == 'Active',
      );
    } catch (e) {
      return null;
    }
  }

  // Update a session
  Future<void> updateSession(Session session) async {
    await isar.writeTxn(() async {
      await isar.sessions.put(session);
    });
  }

  // Complete a session
  Future<void> completeSession(String sessionId) async {
    final session = await getSessionById(sessionId);
    if (session != null) {
      session.endTime = DateTime.now();
      session.durationMinutes = session.calculatedDuration;
      session.status = 'Completed';
      await updateSession(session);
    }
  }

  // Pause a session
  Future<void> pauseSession(String sessionId) async {
    final session = await getSessionById(sessionId);
    if (session != null) {
      session.status = 'Paused';
      await updateSession(session);
    }
  }

  // Resume a session
  Future<void> resumeSession(String sessionId) async {
    final session = await getSessionById(sessionId);
    if (session != null) {
      session.status = 'Active';
      await updateSession(session);
    }
  }

  // Delete a session
  Future<void> deleteSession(String sessionId) async {
    final session = await getSessionById(sessionId);
    if (session != null) {
      await isar.writeTxn(() async {
        await isar.sessions.delete(session.id);
      });
    }
  }

  // Get completed sessions for a goal
  Future<List<Session>> getCompletedSessionsForGoal(String goalId) async {
    final sessions = await isar.sessions.where().findAll();
    return sessions
        .where((s) => s.goalId == goalId && s.status == 'Completed')
        .toList();
  }

  // Get total minutes for a goal
  Future<int> getTotalMinutesForGoal(String goalId) async {
    final sessions = await getCompletedSessionsForGoal(goalId);
    int total = 0;
    for (final session in sessions) {
      total += session.durationMinutes;
    }
    return total;
  }

  // Clear all sessions (for testing)
  Future<void> clearAllSessions() async {
    await isar.writeTxn(() async {
      await isar.sessions.clear();
    });
  }
}
