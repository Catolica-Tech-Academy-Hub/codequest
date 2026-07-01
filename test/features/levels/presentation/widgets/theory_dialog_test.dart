import 'package:codequest/features/levels/domain/entities/level.dart';
import 'package:codequest/features/levels/presentation/widgets/theory_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('teoria nao fecha com o botao voltar do sistema', (
    WidgetTester tester,
  ) async {
    const theory = LevelTheory(
      title: 'Operadores',
      body: 'Use <code>==</code> para comparar.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => showTheoryDialog(context, theory),
                  child: const Text('Abrir'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('TEORIA'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('TEORIA'), findsOneWidget);

    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();

    expect(find.text('TEORIA'), findsNothing);
  });
}
