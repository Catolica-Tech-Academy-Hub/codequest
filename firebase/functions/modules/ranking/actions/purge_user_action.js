class PurgeUserAction {
  constructor(rankingRepository) {
    this.rankingRepository = rankingRepository;
  }

  async execute({ uid }) {
    if (!uid) {
      return { purged: false };
    }

    const user = await this.rankingRepository.getUser(uid);
    const leagueId = user ? user.leagueId : null;

    await this.rankingRepository.deleteUserData(uid, leagueId);

    return { purged: true };
  }
}

module.exports = {
  PurgeUserAction,
};
