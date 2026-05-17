import 'package:codequest/features/activities/domain/entities/activity.dart';
import 'package:codequest/features/activities/presentation/widgets/content_activity_widget.dart';
import 'package:codequest/features/activities/presentation/widgets/multi_choice_activity_widget.dart';
import 'package:codequest/features/activities/presentation/widgets/one_choice_activity_widget.dart';
import 'package:flutter/material.dart';

class ActivityBuilder extends StatelessWidget {
  const ActivityBuilder({
    required this.activity,
    required this.onContinue,
    super.key,
  });

  final Activity activity;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return switch (activity) {
      final OneChoiceActivity a => OneChoiceActivityWidget(
          activity: a,
          onContinue: onContinue,
        ),
      final MultiChoiceActivity a => MultiChoiceActivityWidget(
          activity: a,
          onContinue: onContinue,
        ),
      final ContentActivity c => ContentActivityWidget(
          activity: c,
          onContinue: onContinue,
        ),
    };
  }
}
