import 'package:codequest/features/sample_module/providers/sample_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SamplePage extends ConsumerStatefulWidget {
  const SamplePage({super.key});

  @override
  ConsumerState<SamplePage> createState() => _SamplePageState();
}

class _SamplePageState extends ConsumerState<SamplePage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final title = _controller.text;
    await ref.read(sampleControllerProvider).createItem(title);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sampleItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Módulo Exemplo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Título do item',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _create,
                  child: const Text('Criar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.when(
                data: (items) => ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.title),
                      subtitle: Text(item.createdAt.toIso8601String()),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text(error.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
