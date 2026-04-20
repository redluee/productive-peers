# Productive Peers - Flutter Implementation Guide

## Quick Start

```bash
# 1. Get dependencies
flutter pub get

# 2. Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run
```

## Project Structure

```
lib/
├── core/                          # Shared infrastructure
│   ├── constants/
│   │   ├── app_colors.dart       # Mint #00e3a4, Black #000000
│   │   ├── app_sizes.dart        # Spacing scale (8-48px)
│   │   └── app_strings.dart      # UI labels and localization
│   └── theme/
│       └── app_theme.dart        # Material 3 dark theme
├── models/                        # Isar-compatible data models
│   ├── goal.dart                 # Goal with type, progress, stats
│   ├── session.dart              # Session with timer tracking
│   └── user.dart                 # User profile (stub for Phase 2)
├── data/repositories/            # Data access layer
│   ├── goal_repository.dart      # 11 goal CRUD + stats methods
│   └── session_repository.dart   # 15 session CRUD + tracking methods
├── providers/                     # Riverpod state management
│   ├── goal_provider.dart        # Async goals, sessions, CRUD notifiers
│   └── theme_provider.dart       # Theme switching (for Phase 2)
├── screens/                       # User-facing screens
│   ├── goals/
│   │   ├── goals_screen.dart     # List all goals with FAB
│   │   └── create_goal_screen.dart
│   ├── sessions/
│   │   ├── start_session_screen.dart  # Select goal for session
│   │   └── active_session_screen.dart # Timer with controls
│   ├── notifications/
│   ├── friends/
│   └── profile/
├── widgets/                       # 9 reusable components
│   ├── common/
│   │   ├── bottom_nav_bar.dart   # 5-tab persistent nav
│   │   ├── app_bar_custom.dart
│   │   └── progress_bar.dart
│   ├── goals/
│   │   ├── goal_card.dart        # Displays goal with icon/progress
│   │   ├── goal_form.dart        # Creation/editing form
│   │   └── progress_bar.dart
│   └── sessions/
│       └── session_timer.dart    # MM:SS timer display
├── router/
│   └── app_router.dart           # GoRouter with 5 persistent branches
├── firebase/
│   └── firebase_service.dart     # Optional Firebase init
└── main.dart                      # App entry point
```

## Architecture Patterns

### State Management: Riverpod
- **FutureProviders**: Async data loading from Isar (goals, sessions)
- **StateNotifiers**: Mutations (create, update, delete, pause/resume)
- **Provider.family**: Parameterized access to individual items
- **Automatic Invalidation**: Cache refreshes on mutations

Example:
```dart
// Watch all goals
final goalsAsync = ref.watch(goalsProvider);

// Create goal and refresh cache
await ref.read(createGoalProvider.notifier).createGoal(goal);
// This automatically invalidates goalsProvider
```

### Navigation: GoRouter with StatefulShellRoute
- 5 persistent branches (one per tab)
- Each branch has its own route history
- BottomNavBar uses `goBranch()` to switch without losing state
- Child routes (like /goal/create) nest under parent branches

### Database: Isar
- Offline-first local database
- Auto-increment IDs + UUID sync keys
- Indexes on frequently queried fields (id, createdAt)
- Type-safe query building with generated adapters

## Core Features Implemented

### Goal Management
**Create**: Form with validation → Isar.put() → Provider invalidation
**Read**: getAllGoals() → FutureProvider.watch() → GoalCard widgets
**Update**: updateGoal() → Isar.put() → Cache refresh
**Delete**: deleteGoal() with confirmation → Isar.delete() → List refresh

### Session Tracking
**Start**: Select goal → Navigate to timer → Initialize Session object
**Timer**: Count elapsed time in-memory → Display MM:SS format
**Controls**: Pause (stop counting), Resume (restart), End (save to Isar)
**Statistics**: completeSession() → incrementSessionsCompleted() + addMinutes()

### Statistics Auto-Tracking
```dart
// When session ends:
1. Create Session object with durationMinutes
2. Call sessionRepo.completeSession(sessionId)
3. Call goalRepo.incrementSessionsCompleted(goalId)
4. Call goalRepo.addMinutes(goalId, durationMinutes)
5. Providers automatically invalidate and UI refreshes
```

## UI/UX Design

### Color Scheme (Material 3 Dark)
- **Primary**: Mint #00e3a4
- **Background**: Black #000000
- **Surface**: Dark gray
- **Goal Type Colors**:
  - Habit: Purple #9C27B0
  - Study: Blue #2196F3
  - Goal: Orange #FF9800

### Responsive Design
- Mobile (375px): Single column, full-width cards
- Tablet (600px): Two-column layout with sidebar
- Desktop (1000px+): Three-column with expanded details

## API Reference

### GoalRepository (11 methods)
```dart
Future<Goal> createGoal(Goal goal)
Future<List<Goal>> getAllGoals()
Future<Goal?> getGoalById(String goalId)
Future<void> updateGoal(Goal goal)
Future<void> deleteGoal(String goalId)
Future<List<Goal>> getGoalsByType(String type)
Future<List<Goal>> getPublicGoals()
Future<void> updateGoalProgress(String goalId, double progress)
Future<void> incrementSessionsCompleted(String goalId)
Future<void> addMinutes(String goalId, int minutes)
Future<void> clearAllGoals()
```

### SessionRepository (15 methods)
```dart
Future<Session> createSession(Session session)
Future<List<Session>> getAllSessions()
Future<Session?> getSessionById(String sessionId)
Future<List<Session>> getSessionsByGoalId(String goalId)
Future<List<Session>> getActiveSessions()
Future<Session?> getActiveSessionForGoal(String goalId)
Future<void> updateSession(Session session)
Future<void> completeSession(String sessionId)
Future<void> pauseSession(String sessionId)
Future<void> resumeSession(String sessionId)
Future<void> deleteSession(String sessionId)
Future<List<Session>> getCompletedSessionsForGoal(String goalId)
Future<int> getTotalMinutesForGoal(String goalId)
Future<void> clearAllSessions()
```

## Phase 2 Roadmap

- [ ] Firebase Firestore sync for goals/sessions
- [ ] Firebase Authentication (Google/Email)
- [ ] Push notifications via Firebase Cloud Messaging
- [ ] Social features: friends, emoji reactions, activity feeds
- [ ] Advanced animations and transitions
- [ ] Offline sync strategy implementation
- [ ] Analytics and crash reporting

## Testing Checklist

- [x] Goal creation flow (form → save → list)
- [x] Goal deletion flow (long-press → confirm → delete)
- [x] Session timer flow (start → pause → resume → end)
- [x] Data persistence (close app → reopen → data present)
- [x] Navigation persistence (switch tabs → data not lost)
- [x] Error handling (invalid input → snackbar)
- [x] Compilation (flutter analyze → 0 errors)
- [x] Build (flutter build linux → success)

## Dependencies Overview

| Package | Version | Purpose |
|---------|---------|---------|
| firebase_core | ^3.1.0 | Firebase initialization |
| riverpod | ^2.6.1 | State management core |
| flutter_riverpod | ^2.6.1 | Flutter integration |
| go_router | ^14.2.0 | Navigation and routing |
| isar | ^3.1.0+1 | Local database |
| isar_flutter_libs | ^3.1.0+1 | Platform support for Isar |
| path_provider | ^2.1.5 | Isar storage path |
| heroicons | ^0.7.0 | Vector icons |
| uuid | ^4.0.0 | Unique ID generation |
| intl | ^0.19.0 | Date formatting |

## Performance Considerations

- **Isar Queries**: Indexed by id and createdAt for fast lookups
- **Provider Caching**: FutureProviders cache results until invalidated
- **Widget Rebuilds**: Only affected consumers rebuild on state change
- **Database Transactions**: writeTxn() ensures atomicity for multi-step operations
- **Memory**: Session timer uses local state (not reactive) for 1-second ticks

## Troubleshooting

**"Goal not found" error**: Ensure goalId exists in database before querying
**Session not saving**: Check that completeSession() is called before navigation
**Provider keeps loading**: Verify Isar database initialized in main()
**Navigation not working**: Ensure routes match paths in app_router.dart

## Contributing

1. Follow existing file structure and naming conventions
2. Use Riverpod for new state management features
3. Add Isar @Collection annotations for new models
4. Run code generation: `flutter pub run build_runner build`
5. Verify: `flutter analyze` (should pass with 0 issues)
