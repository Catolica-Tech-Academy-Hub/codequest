import 'package:flutter/material.dart';

class StreakIndicator extends StatelessWidget {
  const StreakIndicator({required this.days, super.key});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.local_fire_department, color: Colors.orange),
        const SizedBox(width: 6),
        Text('$days dias'),
      ],
    );
  }
}
