import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/notifications/presentation/widgets/streak_reminder_badge.dart';
import 'package:codequest/features/notifications/providers/notification_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final prefsAsync = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Nome: ${user?.displayName ?? 'Usuário'}'),
            const SizedBox(height: 6),
            Text('E-mail: ${user?.email ?? '-'}'),
            const SizedBox(height: 12),
            prefsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (prefs) => StreakReminderBadge(
                active: prefs.pushEnabled && prefs.streakReminderEnabled,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.push('/settings/notifications'),
              icon: const Icon(Icons.notifications_outlined),
              label: const Text('Configurar Notificações'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authControllerProvider).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}
