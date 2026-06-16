const TIER_LADDER = ['bronze', 'silver', 'gold', 'diamond'];
const PROMOTION_COUNT = 15;
const DEMOTION_COUNT = 5;

class WeeklyResetAction {
  constructor(rankingRepository) {
    this.rankingRepository = rankingRepository;
  }

  async execute() {
    const leagues = await this.rankingRepository.listLeagues();

    let promoted = 0;
    let demoted = 0;
    let reset = 0;

    for (const league of leagues) {
      const tier = (league.tier || 'bronze').toLowerCase();
      const tierIndex = TIER_LADDER.indexOf(tier);
      const upTier = tierIndex >= 0 ? TIER_LADDER[tierIndex + 1] : null;
      const downTier = tierIndex > 0 ? TIER_LADDER[tierIndex - 1] : null;

      const promoteLeagueId = upTier
        ? await this.rankingRepository.findLeagueIdByTier(upTier)
        : null;
      const demoteLeagueId = downTier
        ? await this.rankingRepository.findLeagueIdByTier(downTier)
        : null;

      const users = await this.rankingRepository.listLeagueUsersByWeeklyXp(
        league.id,
      );

      const promotionSet = new Set(
        users.slice(0, PROMOTION_COUNT).map((u) => u.id),
      );
      const demotionSet = new Set(
        users.slice(Math.max(users.length - DEMOTION_COUNT, 0)).map((u) => u.id),
      );

      const userUpdates = [];

      for (const user of users) {
        const data = { weeklyXp: 0, positionChange: 0 };

        if (promoteLeagueId && promotionSet.has(user.id)) {
          data.leagueId = promoteLeagueId;
          await this.rankingRepository.moveMember({
            uid: user.id,
            name: user.displayName || user.name || 'Aluno',
            fromLeagueId: league.id,
            toLeagueId: promoteLeagueId,
            xp: Number(user.xpTotal) || 0,
          });
          promoted += 1;
        } else if (
          demoteLeagueId &&
          demotionSet.has(user.id) &&
          !promotionSet.has(user.id)
        ) {
          data.leagueId = demoteLeagueId;
          await this.rankingRepository.moveMember({
            uid: user.id,
            name: user.displayName || user.name || 'Aluno',
            fromLeagueId: league.id,
            toLeagueId: demoteLeagueId,
            xp: Number(user.xpTotal) || 0,
          });
          demoted += 1;
        }

        userUpdates.push({ uid: user.id, data });
      }

      await this.rankingRepository.commitUserUpdates(userUpdates);
      reset += userUpdates.length;
    }

    return { reset, promoted, demoted };
  }
}

module.exports = {
  WeeklyResetAction,
};
