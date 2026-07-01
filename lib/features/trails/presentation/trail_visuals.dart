import 'package:codequest/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TrailVisual {
  const TrailVisual({required this.accent, required this.emoji});

  final Color accent;
  final String emoji;
}

class TrailVisuals {
  const TrailVisuals._();

  static const _palette = <TrailVisual>[
    TrailVisual(accent: AppColors.primary, emoji: '📚'),
    TrailVisual(accent: AppColors.bronze, emoji: '⚡'),
    TrailVisual(accent: AppColors.gold, emoji: '🧩'),
    TrailVisual(accent: AppColors.diamond, emoji: '🚀'),
    TrailVisual(accent: AppColors.bronze, emoji: '💩'),
  ];

  static const _overrides = <String, TrailVisual>{};

  static TrailVisual of(String trailId) =>
      _overrides[trailId] ?? _palette[_stableHash(trailId) % _palette.length];

  static int _stableHash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }
}
