import 'package:codequest/features/auth/domain/errors/auth_failure.dart';
import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/profile/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = ref.read(currentUserProvider)?.email;
    if (email == null) return;

    setState(() => _loading = true);
    try {
      await ref.read(profileControllerProvider).updatePassword(
            email: email,
            currentPassword: _currentController.text,
            newPassword: _newController.text,
            confirmPassword: _confirmController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada com sucesso.')),
        );
        Navigator.of(context).pop();
      }
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
        title: const Text('Alterar Senha'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PasswordField(
                        controller: _currentController,
                        label: 'Senha atual',
                        validator: (v) => (v?.isEmpty ?? true)
                            ? 'Informe a senha atual.'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      _PasswordField(
                        controller: _newController,
                        label: 'Nova senha',
                        validator: (v) {
                          final val = v ?? '';
                          if (val.isEmpty) return 'Informe a nova senha.';
                          final hasLetter = RegExp(r'[A-Za-z]').hasMatch(val);
                          final hasNumber = RegExp(r'\d').hasMatch(val);
                          if (val.length < 8 || !hasLetter || !hasNumber) {
                            return 'Senha deve ter 8+ caracteres, letra e numero.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _PasswordField(
                        controller: _confirmController,
                        label: 'Confirmar nova senha',
                        validator: (v) => v != _newController.text
                            ? 'As senhas nao coincidem.'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
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
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: true,
          validator: validator,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            enabledBorder: UnderlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
