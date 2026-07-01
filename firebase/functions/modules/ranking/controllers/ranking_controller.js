class RankingController {
  constructor({
    syncLeagueMemberAction,
    recalculateRankingsAction,
    weeklyResetAction,
    purgeUserAction,
  }) {
    this.syncLeagueMemberAction = syncLeagueMemberAction;
    this.recalculateRankingsAction = recalculateRankingsAction;
    this.weeklyResetAction = weeklyResetAction;
    this.purgeUserAction = purgeUserAction;
  }

  onLessonCompleted = async (event) => {
    const uid = event.params?.uid;
    const progress = event.data?.data();
    if (!uid || !progress) {
      return;
    }
    await this.syncLeagueMemberAction.execute({ uid, progress });
  };

  recalculateLeagueRankings = async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!after) {
      return;
    }
    if (
      before &&
      Number(before.xpTotal) === Number(after.xpTotal) &&
      before.leagueId === after.leagueId
    ) {
      return;
    }
    await this.recalculateRankingsAction.execute({ leagueId: after.leagueId });
  };

  weeklyReset = async () => {
    await this.weeklyResetAction.execute();
  };

  onUserDeleted = async (user) => {
    await this.purgeUserAction.execute({ uid: user.uid });
  };
}

module.exports = {
  RankingController,
};
