const admin = require('firebase-admin');
const { StatisticsRepository } = require('./repositories/statistics_repository');
const { GetPlayerStatsAction } = require('./actions/get_player_stats_action');
const { GetXpHistoryAction } = require('./actions/get_xp_history_action');
const { StatisticsController } = require('./controllers/statistics_controller');

function createStatisticsModule() {
  const db = admin.firestore();
  const repository = new StatisticsRepository({ db });

  return new StatisticsController({
    getPlayerStatsAction: new GetPlayerStatsAction(repository),
    getXpHistoryAction: new GetXpHistoryAction(repository),
  });
}

module.exports = {
  createStatisticsModule,
};
