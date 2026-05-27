import 'package:codequest/features/auth/domain/errors/auth_failure.dart';
import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/profile/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool? _notificationsEnabled;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final user = ref.watch(currentUserProvider);

    profileAsync.whenData((profile) {
      _notificationsEnabled ??= profile?.notificationsEnabled ?? true;
    });

    final notificationsValue = _notificationsEnabled ?? true;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Configurações de Conta'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Alterar senha'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => context.push('/settings/change-password'),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Notificações'),
                    secondary: const SizedBox.shrink(),
                    value: notificationsValue,
                    activeThumbColor: Theme.of(context).colorScheme.error,
                    onChanged: profileAsync.isLoading
                        ? null
                        : (value) =>
                            setState(() => _notificationsEnabled = value),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(
                      'Excluir conta',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onTap: () => context.push('/settings/delete-account'),
                  ),
                  const Divider(height: 24),
                  ListTile(
                    title: const Text('Sair da conta'),
                    onTap: _signOut,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_saving || user == null) ? null : () => _save(user.uid),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(String uid) async {
    setState(() => _saving = true);
    try {
      await ref.read(profileControllerProvider).updateNotifications(
            uid: uid,
            enabled: _notificationsEnabled ?? true,
          );
      ref.invalidate(currentUserProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configurações salvas.')),
        );
      }
    } on AuthFailure catch (e) {
      _showSnack(e.message);
    } catch (_) {
      _showSnack(AuthFailure.unexpected().message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    await ref.read(authControllerProvider).signOut();
    if (mounted) context.go('/login');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
