import 'package:codequest/features/trails/domain/entities/trail.dart';
import 'package:flutter/material.dart';

class TrailCard extends StatelessWidget {
  const TrailCard({required this.trail, required this.onTap, super.key});

  final Trail trail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(trail.title, style: theme.textTheme.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(trail.description),
              const SizedBox(height: 4),
              Text(
                '${trail.levelIds.length} níveis',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
