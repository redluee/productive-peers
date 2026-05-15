import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/goal.dart';
import '../screens/goals/goals_screen.dart';
import '../screens/goals/create_goal_screen.dart';
import '../screens/goals/goal_detail_screen.dart';
import '../screens/sessions/start_session_screen.dart';
import '../screens/sessions/active_session_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/friends/friends_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../widgets/common/bottom_nav_bar.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: BottomNavBar(navigationShell: navigationShell),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'goals',
              builder: (context, state) => const GoalsScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'createGoal',
                  builder: (context, state) {
                    final initialGoal =
                        state.extra is Goal ? state.extra as Goal : null;
                    return CreateGoalScreen(initialGoal: initialGoal);
                  },
                ),
                GoRoute(
                  path: ':goalId',
                  name: 'goalDetail',
                  builder: (context, state) {
                    final goalId = state.pathParameters['goalId']!;
                    return GoalDetailScreen(goalId: goalId);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notifications',
              name: 'notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/session/start',
              name: 'startSession',
              builder: (context, state) => const StartSessionScreen(),
              routes: [
                GoRoute(
                  path: 'active/:goalId',
                  name: 'activeSession',
                  builder: (context, state) {
                    final goalId = state.pathParameters['goalId']!;
                    return ActiveSessionScreen(goalId: goalId);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/friends',
              name: 'friends',
              builder: (context, state) => const FriendsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
