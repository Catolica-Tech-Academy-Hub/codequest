class RecalculateRankingsAction {
  constructor(rankingRepository) {
    this.rankingRepository = rankingRepository;
  }

  async execute({ leagueId }) {
    if (!leagueId) {
      return { recalculated: false };
    }

    const users = await this.rankingRepository.listLeagueUsersByXp(leagueId);

    const userUpdates = [];
    const memberUpdates = [];

    users.forEach((user, index) => {
      const newPosition = index + 1;
      const previousPosition = Number(user.position) || newPosition;
      const positionChange = previousPosition - newPosition;

      const positionChanged = Number(user.position) !== newPosition;
      const deltaChanged = Number(user.positionChange) !== positionChange;

      if (positionChanged || deltaChanged) {
        userUpdates.push({
          uid: user.id,
          data: { position: newPosition, positionChange },
        });
        memberUpdates.push({
          leagueId,
          uid: user.id,
          data: { position: newPosition, deltaPosition: positionChange },
        });
      }
    });

    await this.rankingRepository.commitUserUpdates(userUpdates);
    await this.rankingRepository.commitMemberUpdates(memberUpdates);

    return { recalculated: true, updated: userUpdates.length };
  }
}

module.exports = {
  RecalculateRankingsAction,
};
