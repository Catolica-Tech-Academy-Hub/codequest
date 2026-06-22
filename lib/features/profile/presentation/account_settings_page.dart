import 'package:flutter/material.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Conta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Alterar senha'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: SwitchListTile(
                value: true,
                onChanged: (_) {},
                title: const Text('Notificações'),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                title: const Text(
                  'Excluir conta',
                  style: TextStyle(color: Colors.red),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.red,
                ),
                onTap: () {},
              ),
            ),

            const Spacer(),

            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}