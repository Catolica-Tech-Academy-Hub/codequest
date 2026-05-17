import 'package:codequest/features/activities/domain/entities/activity.dart';
import 'package:codequest/features/activities/domain/entities/activity_result.dart';
import 'package:codequest/features/activities/domain/value_objects/answer_key.dart';
import 'package:codequest/features/activities/presentation/widgets/answer_option_tile.dart';
import 'package:codequest/features/activities/presentation/widgets/rich_activity_text.dart';
import 'package:codequest/features/activities/providers/activity_providers.dart';
import 'package:codequest/shared/widgets/feedback_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OneChoiceActivityWidget extends ConsumerStatefulWidget {
  const OneChoiceActivityWidget({
    required this.activity,
    required this.onContinue,
    super.key,
  });

  final OneChoiceActivity activity;
  final VoidCallback onContinue;

  @override
  ConsumerState<OneChoiceActivityWidget> createState() => _OneChoiceActivityWidgetState();
}

class _OneChoiceActivityWidgetState extends ConsumerState<OneChoiceActivityWidget> {
  AnswerKey? _selected;
  ActivityResult? _result;

  void _select(AnswerKey key) {
    if (_result != null) return;
    setState(() => _selected = key);
  }

  Future<void> _submit() async {
    final selected = _selected;
    if (selected == null) return;
    final result = ref
        .read(activityControllerProvider)
        .evaluate(widget.activity, <AnswerKey>{selected});
    setState(() => _result = result);

    if (!mounted) return;
    await showFeedbackModal(
      context,
      status: result.correct ? FeedbackStatus.correct : FeedbackStatus.wrong,
      message: _messageFor(result),
      onContinue: widget.onContinue,
    );
  }

  String _messageFor(ActivityResult result) {
    if (result.correct) {
      return 'Você completou o exercício corretamente!';
    }
    final expected = result.expected
        .map((k) => widget.activity.options[k] ?? k.value.toUpperCase())
        .join(', ');
    return 'A resposta correta era: $expected';
  }

  AnswerTileState _stateFor(AnswerKey key) {
    final result = _result;
    if (result == null) {
      return _selected == key ? AnswerTileState.selected : AnswerTileState.idle;
    }
    final isExpected = result.expected.contains(key);
    final isSelected = result.selected.contains(key);
    if (isSelected && isExpected) return AnswerTileState.correct;
    if (isSelected && !isExpected) return AnswerTileState.incorrect;
    if (!isSelected && isExpected) return AnswerTileState.missed;
    return AnswerTileState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final entries = activity.options.entries.toList()
      ..sort((a, b) => a.key.value.compareTo(b.key.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        RichActivityText(
          activity.question,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        for (final entry in entries)
          AnswerOptionTile(
            label: entry.key.value,
            text: entry.value,
            state: _stateFor(entry.key),
            onTap: _result == null ? () => _select(entry.key) : null,
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _selected == null || _result != null ? null : _submit,
          child: const Text('Verificar'),
        ),
      ],
    );
  }
}
