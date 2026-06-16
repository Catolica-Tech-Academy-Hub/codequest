import 'package:codequest/features/auth/domain/errors/auth_failure.dart';
import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/shared/widgets/app_button.dart';
import 'package:codequest/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) {
        context.go('/home/trails');
      }
    } on AuthFailure catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage(AuthFailure.unexpected().message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Informe o e-mail para resetar a senha.');
      return;
    }

    try {
      await ref.read(authControllerProvider).sendPasswordReset(email);
      _showMessage('E-mail de recuperacao enviado.');
    } on AuthFailure catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage(AuthFailure.unexpected().message);
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _validateEmail(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Informe o e-mail';
    }

    final isValid = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    ).hasMatch(raw);

    if (!isValid) {
      return 'Informe um e-mail valido';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);

    if (password.isEmpty) {
      return 'Informe a senha';
    }

    if (password.length < 8 || !hasLetter || !hasNumber) {
      return 'Senha deve ter 8+ caracteres, com letra e numero';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar no CodeQuest')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppTextField(
                      controller: _emailController,
                      label: 'E-mail',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Senha',
                      obscureText: true,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Entrar',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    TextButton(
                      onPressed: _loading ? null : _resetPassword,
                      child: const Text('Esqueci minha senha'),
                    ),
                    TextButton(
                      onPressed: _loading ? null : () => context.go('/register'),
                      child: const Text('Criar conta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
