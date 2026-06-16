import 'package:flutter/material.dart';

class XpBadge extends StatelessWidget {
  const XpBadge({required this.xp, super.key});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.bolt, size: 16),
      label: Text('$xp XP'),
    );
  }
}
