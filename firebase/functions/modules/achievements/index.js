const admin = require('firebase-admin');
const { FirestoreDefinitionsSource } = require('./definitions/firestore_definitions_source');
const { AchievementRepository } = require('./repositories/achievement_repository');
const { CheckAchievementsAction } = require('./actions/check_achievements_action');

function createAchievementsModule() {
  const db = admin.firestore();
  const definitionsSource = new FirestoreDefinitionsSource({ db });
  const repository = new AchievementRepository({ db });

  return new CheckAchievementsAction({ definitionsSource, repository });
}

module.exports = {
  createAchievementsModule,
};
