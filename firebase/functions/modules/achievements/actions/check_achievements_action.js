const { evaluateCondition } = require('../domain/evaluate_condition');

class CheckAchievementsAction {
  constructor({ definitionsSource, repository }) {
    this._definitionsSource = definitionsSource;
    this._repository = repository;
  }

  async execute(uid) {
    const [definitions, stats, unlockedIds] = await Promise.all([
      this._definitionsSource.getAll(),
      this._repository.getUserStats(uid),
      this._repository.getUnlockedIds(uid),
    ]);

    const unlocked = [];
    for (const achievement of definitions) {
      // Curto-circuito da dedup: já desbloqueada nem chega a avaliar a condição.
      if (unlockedIds.has(achievement.id)) {
        continue;
      }
      if (!evaluateCondition(achievement.condition, stats)) {
        continue;
      }

      await this._repository.unlock(uid, achievement.id);
      const { id, name, description, iconKey, tier, category } = achievement;
      unlocked.push({ id, name, description, iconKey, tier, category });
    }

    return { unlocked };
  }
}

module.exports = {
  CheckAchievementsAction,
};
