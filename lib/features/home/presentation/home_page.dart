import 'package:codequest/features/achievements/presentation/achievements_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Entrar no jogo: verifica conquistas uma vez ao montar a shell autenticada.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        triggerAchievementsCheck(ref, context);
      }
    });
  }

  int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home/ranking')) {
      return 1;
    }
    if (location.startsWith('/home/achievements')) {
      return 2;
    }
    if (location.startsWith('/home/profile')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateIndex(context),
        onDestinationSelected: (int index) {
          if (index == 0) {
            context.go('/home/trails');
            return;
          }
          if (index == 1) {
            context.go('/home/ranking');
            return;
          }
          if (index == 2) {
            context.go('/home/achievements');
            return;
          }
          context.go('/home/profile');
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.map), label: 'Trilhas'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Ranking'),
          NavigationDestination(icon: Icon(Icons.workspace_premium), label: 'Conquistas'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
