import 'dart:async';

import 'package:codequest/features/code_sorting/presentation/code_sorting_page.dart';
import 'package:codequest/features/levels/presentation/level_page.dart';
import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/auth/presentation/login_page.dart';
import 'package:codequest/features/auth/presentation/register_page.dart';
import 'package:codequest/features/home/presentation/home_page.dart';
import 'package:codequest/features/profile/presentation/profile_page.dart';
import 'package:codequest/features/ranking/presentation/ranking_page.dart';
import 'package:codequest/features/trails/presentation/trail_detail_page.dart';
import 'package:codequest/features/trails/presentation/trails_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codequest/screens/notification_settings_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // HOTFIX: mantém o authStateProvider vivo para o ref.read dentro do redirect enxergar AsyncData em vez de loading
  ref.listen(authStateProvider, (_, __) {});
  final authRefreshNotifier = _StreamRouterRefreshNotifier(
    ref.watch(observeAuthStateActionProvider).call(),
  );
  ref.onDispose(authRefreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authRefreshNotifier,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        redirect: (BuildContext context, GoRouterState state) => '/home/trails',
      ),
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return HomePage(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home/trails',
            builder: (BuildContext context, GoRouterState state) => const TrailsPage(),
          ),
          GoRoute(
            path: '/home/ranking',
            builder: (BuildContext context, GoRouterState state) => const RankingScreen(),
          ),
          GoRoute(
            path: '/home/profile',
            builder: (BuildContext context, GoRouterState state) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/trail/:trailId',
        builder: (BuildContext context, GoRouterState state) {
          return TrailDetailPage(
            trailId: state.pathParameters['trailId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/level/:levelId',
        builder: (BuildContext context, GoRouterState state) {
          return LevelPage(
            levelId: state.pathParameters['levelId'] ?? '',
            trailId: state.uri.queryParameters['trailId'],
          );
        },
      ),
GoRoute(
  path: '/notification-settings',
  builder: (BuildContext context, GoRouterState state) {
    return const AppShell();
  },
),
GoRoute(
  path: '/challenge/code-sorting/:challengeId',
  builder: (BuildContext context, GoRouterState state) {
    return CodeSortingPage(
      challengeId: state.pathParameters['challengeId'] ?? '',
      userId: state.extra as String? ?? '',
    );
  },
),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authStateProvider);
      if (authState.isLoading) {
        return null;
      }

      final bool isAuthenticated = authState.value != null;
      final String location = state.matchedLocation;
      final bool isAuthRoute = location == '/login' || location == '/register';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && (isAuthRoute || location == '/')) {
        return '/home/trails';
      }

      return null;
    },
  );
});

class _StreamRouterRefreshNotifier extends ChangeNotifier {
  _StreamRouterRefreshNotifier(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
