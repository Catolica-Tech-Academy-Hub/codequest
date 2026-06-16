const { RankingRepository } = require('./repositories/ranking_repository');
const {
  SyncLeagueMemberAction,
} = require('./actions/sync_league_member_action');
const {
  RecalculateRankingsAction,
} = require('./actions/recalculate_rankings_action');
const { WeeklyResetAction } = require('./actions/weekly_reset_action');
const { PurgeUserAction } = require('./actions/purge_user_action');
const { RankingController } = require('./controllers/ranking_controller');

function createRankingModule() {
  const repository = new RankingRepository();

  return new RankingController({
    syncLeagueMemberAction: new SyncLeagueMemberAction(repository),
    recalculateRankingsAction: new RecalculateRankingsAction(repository),
    weeklyResetAction: new WeeklyResetAction(repository),
    purgeUserAction: new PurgeUserAction(repository),
  });
}

module.exports = {
  createRankingModule,
};
