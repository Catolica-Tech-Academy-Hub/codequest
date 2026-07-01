enum AchievementTier {
  common,
  rare,
  epic,
  legendary;

  static AchievementTier fromKey(String? key) {
    return AchievementTier.values.firstWhere(
      (tier) => tier.name == key,
      orElse: () => AchievementTier.common,
    );
  }
}

class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconKey,
    required this.tier,
    required this.category,
  });

  final String id;
  final String name;
  final String description;
  final String iconKey;
  final AchievementTier tier;
  final String category;
}
