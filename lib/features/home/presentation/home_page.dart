import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.child, super.key});

  final Widget child;

  int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home/ranking')) {
      return 1;
    }
    if (location.startsWith('/home/profile')) {
      return 2;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
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
          context.go('/home/profile');
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.map), label: 'Trilhas'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Ranking'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
