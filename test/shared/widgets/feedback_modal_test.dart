import 'package:codequest/shared/widgets/feedback_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe o modal e executa onContinue ao confirmar', (
    WidgetTester tester,
  ) async {
    var continued = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => showFeedbackModal(
                    context,
                    status: FeedbackStatus.correct,
                    message: 'Tudo certo',
                    onContinue: () {
                      continued = true;
                    },
                  ),
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

    expect(find.text('Excelente!'), findsOneWidget);
    expect(find.text('Tudo certo'), findsOneWidget);

    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();

    expect(continued, isTrue);
    expect(find.text('Excelente!'), findsNothing);
  });
}
