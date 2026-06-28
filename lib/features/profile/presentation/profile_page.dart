import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

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
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.push('/statistics'),
              icon: const Icon(Icons.insights),
              label: const Text('Ver estatísticas da conta'),
            ),
            const SizedBox(height: 16),
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
