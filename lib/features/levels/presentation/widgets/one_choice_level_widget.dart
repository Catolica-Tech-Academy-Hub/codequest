import 'package:codequest/features/levels/domain/entities/level.dart';
import 'package:codequest/features/levels/domain/entities/level_result.dart';
import 'package:codequest/features/levels/domain/value_objects/answer_key.dart';
import 'package:codequest/features/levels/presentation/widgets/answer_option_tile.dart';
import 'package:codequest/features/levels/presentation/widgets/rich_level_text.dart';
import 'package:codequest/features/levels/presentation/widgets/theory_dialog.dart';
import 'package:codequest/features/levels/providers/level_providers.dart';
import 'package:codequest/shared/widgets/feedback_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OneChoiceLevelWidget extends ConsumerStatefulWidget {
  const OneChoiceLevelWidget({
    required this.level,
    required this.onContinue,
    super.key,
  });

  final OneChoiceLevel level;
  final VoidCallback onContinue;

  @override
  ConsumerState<OneChoiceLevelWidget> createState() => _OneChoiceLevelWidgetState();
}

class _OneChoiceLevelWidgetState extends ConsumerState<OneChoiceLevelWidget> {
  AnswerKey? _selected;
  LevelResult? _result;

  @override
  void initState() {
    super.initState();
    // RF05: exibe a Teoria em pop-up antes do exercício, após o primeiro frame.
    final theory = widget.level.theory;
    if (theory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showTheoryDialog(context, theory);
      });
    }
  }

  void _select(AnswerKey key) {
    if (_result != null) return;
    setState(() => _selected = key);
  }

  Future<void> _submit() async {
    final selected = _selected;
    if (selected == null) return;
    final result = ref
        .read(levelControllerProvider)
        .evaluate(widget.level, <AnswerKey>{selected});
    setState(() => _result = result);

    if (!mounted) return;
    await showFeedbackModal(
      context,
      status: result.correct ? FeedbackStatus.correct : FeedbackStatus.wrong,
      message: _messageFor(result),
      onContinue: widget.onContinue,
    );
  }

  String _messageFor(LevelResult result) {
    if (result.correct) {
      return 'Você completou o exercício corretamente!';
    }
    final expected = result.expected
        .map((k) => widget.level.options[k] ?? k.value.toUpperCase())
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
    final level = widget.level;
    final entries = level.options.entries.toList()
      ..sort((a, b) => a.key.value.compareTo(b.key.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        RichLevelText(
          level.question,
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
