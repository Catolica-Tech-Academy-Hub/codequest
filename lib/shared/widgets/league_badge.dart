import 'package:codequest/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LeagueBadge extends StatelessWidget {
  const LeagueBadge({required this.league, super.key});

  final String league;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: _colorForLeague(league),
      label: Text(league),
    );
  }

  Color _colorForLeague(String value) {
    switch (value.toLowerCase()) {
      case 'bronze':
        return AppColors.bronze;
      case 'prata':
      case 'silver':
        return AppColors.silver;
      case 'ouro':
      case 'gold':
        return AppColors.gold;
      case 'diamante':
      case 'diamond':
        return AppColors.diamond;
      default:
        return Colors.grey;
    }
  }
}
