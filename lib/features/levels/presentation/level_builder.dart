import 'package:codequest/features/levels/domain/entities/level.dart';
import 'package:codequest/features/levels/presentation/widgets/content_level_widget.dart';
import 'package:codequest/features/levels/presentation/widgets/multi_choice_level_widget.dart';
import 'package:codequest/features/levels/presentation/widgets/one_choice_level_widget.dart';
import 'package:flutter/material.dart';

class LevelBuilder extends StatelessWidget {
  const LevelBuilder({
    required this.level,
    required this.onContinue,
    super.key,
  });

  final Level level;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return switch (level) {
      final OneChoiceLevel a => OneChoiceLevelWidget(
          level: a,
          onContinue: onContinue,
        ),
      final MultiChoiceLevel a => MultiChoiceLevelWidget(
          level: a,
          onContinue: onContinue,
        ),
      final ContentLevel c => ContentLevelWidget(
          level: c,
          onContinue: onContinue,
        ),
    };
  }
}
