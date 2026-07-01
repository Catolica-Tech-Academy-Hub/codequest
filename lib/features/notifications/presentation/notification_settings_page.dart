import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/notifications/domain/entities/notification_preferences.dart';
import 'package:codequest/features/notifications/providers/notification_providers.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  NotificationPreferences? _prefs;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(notificationPreferencesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 12),
                Text(
                  'Erro ao carregar preferências',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.invalidate(notificationPreferencesProvider),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
        data: (prefs) {
          _prefs ??= prefs;
          final current = _prefs!;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _SectionHeader(title: 'Push Notifications'),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active_outlined),
                title: const Text('Notificações push'),
                subtitle: const Text(
                  'Receber alertas e atualizações no dispositivo',
                ),
                value: current.pushEnabled,
                onChanged: _saving ? null : (v) => _togglePush(v),
              ),
              const Divider(indent: 16, endIndent: 16),
              _SectionHeader(title: 'Lembretes'),
              SwitchListTile(
                secondary: const Icon(Icons.local_fire_department_outlined),
                title: const Text('Lembrete de streak'),
                subtitle: const Text(
                  'Lembrete às 20h se não completou atividade no dia',
                ),
                value: current.streakReminderEnabled,
                onChanged: current.pushEnabled && !_saving
                    ? (v) => _updatePref(
                          current.copyWith(streakReminderEnabled: v),
                        )
                    : null,
              ),
              const Divider(indent: 16, endIndent: 16),
              _SectionHeader(title: 'Liga'),
              SwitchListTile(
                secondary: const Icon(Icons.emoji_events_outlined),
                title: const Text('Avisos de promoção'),
                subtitle: const Text(
                  'Notificação ao ser promovido de liga',
                ),
                value: current.promotionAlertsEnabled,
                onChanged: current.pushEnabled && !_saving
                    ? (v) => _updatePref(
                          current.copyWith(promotionAlertsEnabled: v),
                        )
                    : null,
              ),
              const Divider(indent: 16, endIndent: 16),
              _SectionHeader(title: 'E-mail'),
              SwitchListTile(
                secondary: const Icon(Icons.email_outlined),
                title: const Text('E-mails de avisos'),
                subtitle: const Text(
                  'Boas-vindas, promoção de liga e outros avisos',
                ),
                value: current.emailEnabled,
                onChanged: _saving
                    ? null
                    : (v) => _updatePref(current.copyWith(emailEnabled: v)),
              ),
              if (_saving)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _togglePush(bool enable) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    if (enable) {
      final granted = await ref.read(fcmServiceProvider).requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permissão negada. Habilite as notificações nas '
                'configurações do dispositivo.',
              ),
            ),
          );
        }
        return;
      }

      final newPrefs = _prefs!.copyWith(pushEnabled: true);
      await _updatePref(newPrefs);

      try {
        final token = await ref.read(fcmServiceProvider).getToken();
        if (token != null) {
          await ref
              .read(notificationRepositoryProvider)
              .saveFcmToken(user.uid, token);
        }
      } catch (_) {}
    } else {
      final newPrefs = _prefs!.copyWith(
        pushEnabled: false,
        streakReminderEnabled: false,
        promotionAlertsEnabled: false,
      );
      await _updatePref(newPrefs);

      try {
        final token = await ref.read(fcmServiceProvider).getToken();
        if (token != null) {
          await ref
              .read(notificationRepositoryProvider)
              .removeFcmToken(user.uid, token);
        }
        await ref.read(localNotificationServiceProvider).cancelStreakReminder();
      } catch (_) {}
    }
  }

  Future<void> _updatePref(NotificationPreferences newPrefs) async {
    final oldPrefs = _prefs;
    setState(() {
      _prefs = newPrefs;
      _saving = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      await ref
          .read(saveNotificationPreferencesActionProvider)
          .call(user.uid, newPrefs);

      if (newPrefs.streakReminderEnabled && newPrefs.pushEnabled) {
        await ref.read(scheduleStreakReminderActionProvider).call(user.uid);
      } else {
        await ref.read(localNotificationServiceProvider).cancelStreakReminder();
      }

      ref.invalidate(notificationPreferencesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferências salvas'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      setState(() => _prefs = oldPrefs);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar preferências. Tente novamente.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
