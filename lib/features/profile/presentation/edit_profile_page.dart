import 'package:codequest/features/auth/domain/errors/auth_failure.dart';
import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/profile/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _nameController = TextEditingController();
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _bioController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _initFields() {
    if (_initialized) return;
    _initialized = true;
    final user = ref.read(currentUserProvider);
    _nameController.text = user?.displayName ?? '';
    ref.read(currentUserProfileProvider).whenData((profile) {
      _bioController.text = profile?.bio ?? '';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _loading = true);
    try {
      await ref.read(profileControllerProvider).updateProfile(
            uid: user.uid,
            name: _nameController.text.trim(),
            bio: _bioController.text,
          );
      ref.invalidate(currentUserProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso.')),
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

  String _nameInitials() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    _initFields();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const SizedBox.shrink(),
        actions: [
          _loading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _submit,
                  child: const Text(
                    'Salvar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          _nameInitials(),
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Editar',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _FieldLabel(label: 'Recado'),
                TextFormField(
                  controller: _bioController,
                  maxLength: 160,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    counterText: '',
                    suffixIcon: Icon(Icons.arrow_forward),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value?.length ?? 0) > 160) {
                      return 'O recado deve ter no maximo 160 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _FieldLabel(label: 'Nome'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.arrow_forward),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.length < 2 || v.length > 50) {
                      return 'Nome deve ter entre 2 e 50 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _FieldLabel(label: 'Email'),
                Builder(
                  builder: (context) {
                    final user = ref.watch(currentUserProvider);
                    return TextFormField(
                      initialValue: user?.email ?? '',
                      readOnly: true,
                      decoration: InputDecoration(
                        suffixIcon: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        border: const UnderlineInputBorder(),
                        enabledBorder: const UnderlineInputBorder(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
      ),
    );
  }
}
