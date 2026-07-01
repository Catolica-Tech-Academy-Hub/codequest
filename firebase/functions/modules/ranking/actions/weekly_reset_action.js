const admin = require('firebase-admin');
const { createPromotionNotification } = require('../../notifications');

const TIER_LADDER = ['bronze', 'silver', 'gold', 'diamond'];
const AVATAR_REWARD_COUNT = 3;
const PROMOTION_COUNT = 15;
const DEMOTION_COUNT = 5;

/**
 * Segunda-feira 00:00 UTC da semana que acabou de fechar.
 * O reset roda na segunda; o XP semanal (`weeklyXp`) foi acumulado na semana
 * anterior, então o snapshot é chaveado pela segunda dessa semana encerrada.
 */
function closingWeekStart(now = new Date()) {
  const date = new Date(
    Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()),
  );
  const dayOfWeek = date.getUTCDay(); // 0=domingo, 1=segunda
  const daysSinceMonday = (dayOfWeek + 6) % 7;
  date.setUTCDate(date.getUTCDate() - daysSinceMonday - 7);
  return date;
}

class WeeklyResetAction {
  constructor(rankingRepository) {
    this.rankingRepository = rankingRepository;
  }

  async execute() {
    const leagues = await this.rankingRepository.listLeagues();

    const weekStart = closingWeekStart();
    const weekStartId = weekStart.toISOString().slice(0, 10);
    const snapshots = [];

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

      users.forEach((user, index) => {
        // Snapshot da evolução temporal antes de zerar: weeklyXp é o XP ganho
        // na semana; xpTotal é o acumulado; position vem do recálculo (fallback
        // para a ordem por weeklyXp da liga).
        snapshots.push({
          uid: user.id,
          weekStartId,
          data: {
            weekStart,
            xpTotal: Number(user.xpTotal) || 0,
            xpGained: Number(user.weeklyXp) || 0,
            position: Number(user.position) || index + 1,
            streakDays: Number(user.streakDays) || 0,
          },
        });
      });

      for (const [index, user] of users.entries()) {
        const data = { weeklyXp: 0, positionChange: 0 };

        if (index < AVATAR_REWARD_COUNT) {
          data.unlockedAvatars = admin.firestore.FieldValue.arrayUnion(
            `avatar_${tier}_${index + 1}`,
          );
        }

        if (promoteLeagueId && promotionSet.has(user.id)) {
          data.leagueId = promoteLeagueId;
          await this.rankingRepository.moveMember({
            uid: user.id,
            name: user.displayName || user.name || 'Aluno',
            fromLeagueId: league.id,
            toLeagueId: promoteLeagueId,
            xpTotal: Number(user.xpTotal) || 0,
          });
          await createPromotionNotification(user.id, tier, upTier);
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
            xpTotal: Number(user.xpTotal) || 0,
          });
          demoted += 1;
        }

        userUpdates.push({ uid: user.id, data });
      }

      await this.rankingRepository.commitUserUpdates(userUpdates);
      reset += userUpdates.length;
    }

    await this.rankingRepository.writeXpHistorySnapshots(snapshots);

    return { reset, promoted, demoted, snapshots: snapshots.length };
  }
}

module.exports = {
  WeeklyResetAction,
};
