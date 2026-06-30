import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/notifications/presentation/widgets/streak_reminder_badge.dart';
import 'package:codequest/features/notifications/providers/notification_providers.dart';
import 'package:codequest/features/profile/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final prefsAsync = ref.watch(notificationPreferencesProvider);

    final name = user?.displayName ?? 'Usuário';
    final email = user?.email ?? '-';
    final initials = _initials(name);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  initials,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                email,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              profileAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (profile) {
                  final bio = profile?.bio;
                  if (bio == null || bio.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                },
              ),
              prefsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (prefs) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: StreakReminderBadge(
                      active: prefs.pushEnabled && prefs.streakReminderEnabled,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => context.push('/settings/edit-profile'),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar Perfil'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/settings/notifications'),
                icon: const Icon(Icons.notifications_outlined),
                label: const Text('Configurar Notificações'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
