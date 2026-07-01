class SyncLeagueMemberAction {
  constructor(rankingRepository) {
    this.rankingRepository = rankingRepository;
  }

  async execute({ uid, progress }) {
    const awardedXp = Number(progress?.xpAwarded) || 0;
    if (awardedXp <= 0) {
      return { synced: false };
    }

    const user = await this.rankingRepository.getUser(uid);
    if (!user || !user.leagueId) {
      return { synced: false };
    }

    await this.rankingRepository.incrementUserWeeklyXp(uid, awardedXp);
    await this.rankingRepository.syncLeagueMember({
      leagueId: user.leagueId,
      uid,
      name: user.displayName || user.name || 'Aluno',
      xpTotal: Number(user.xpTotal) || 0,
      awardedXp,
    });

    return { synced: true, leagueId: user.leagueId, awardedXp };
  }
}

module.exports = {
  SyncLeagueMemberAction,
};
