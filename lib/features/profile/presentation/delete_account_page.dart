import 'package:codequest/features/auth/domain/errors/auth_failure.dart';
import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/profile/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteAccountPage extends ConsumerStatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  ConsumerState<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends ConsumerState<DeleteAccountPage> {
  bool _confirmed = false;
  bool _loading = false;

  Future<void> _delete() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _loading = true);
    try {
      await ref.read(profileControllerProvider).deleteAccount(uid: user.uid);
      // GoRouter detecta a mudança de auth e navega para /login automaticamente
    } on AuthFailure catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(AuthFailure.unexpected().message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Excluir Conta'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Tem certeza de que deseja excluir sua conta? '
                'Essa ação é irreversível e resultará na perda de todos os seus dados.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              CheckboxListTile(
                value: _confirmed,
                onChanged: (v) => setState(() => _confirmed = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text('Confirmo que desejo excluir minha conta'),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      onPressed: (_confirmed && !_loading) ? _delete : null,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Excluir'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
