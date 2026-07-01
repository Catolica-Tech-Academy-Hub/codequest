const admin = require('firebase-admin');
const { onRequest, onCall, HttpsError } = require('firebase-functions/v2/https');
const { onDocumentCreated, onDocumentWritten } = require('firebase-functions/v2/firestore');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const functionsV1 = require('firebase-functions/v1');
const { createSampleModule } = require('./modules/sample');
const { createAchievementsModule } = require('./modules/achievements');
const { createRankingModule } = require('./modules/ranking');
const { createStatisticsModule } = require('./modules/statistics');
const { createUserModule } = require('./modules/user');
const { processMailDocument, sendWelcomeEmail } = require('./modules/notifications');

admin.initializeApp();

const sampleController = createSampleModule();
const checkAchievementsAction = createAchievementsModule();
const rankingController = createRankingModule();
const statisticsController = createStatisticsModule();
const userController = createUserModule();

// HTTP Trigger - Health check
exports.health = onRequest((request, response) => {
  response.status(200).json({
    status: 'ok',
    service: 'codequest-functions',
    timestamp: new Date().toISOString(),
  });
});

// HTTP Trigger - Sample
exports.sampleApi = onRequest(async (request, response) => {
  if (request.method === 'GET') {
    await sampleController.list(request, response);
    return;
  }

  if (request.method === 'POST') {
    await sampleController.create(request, response);
    return;
  }

  response.status(405).json({ message: 'Method not allowed' });
});

exports.checkAchievements = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Necessário estar autenticado.');
  }

  return checkAchievementsAction.execute(uid);
});

exports.getPlayerStats = onCall((request) =>
  statisticsController.getPlayerStats(request),
);

exports.getXpHistory = onCall((request) =>
  statisticsController.getXpHistory(request),
);

exports.updateUserProfile = onCall(userController.updateProfile);

exports.updateUserNotifications = onCall(userController.updateNotifications);

exports.deleteUserAccount = onCall(userController.deleteAccount);

exports.onLessonCompleted = onDocumentCreated(
  'users/{uid}/progress/{progressId}',
  (event) => rankingController.onLessonCompleted(event),
);

exports.recalculateLeagueRankings = onDocumentWritten(
  'users/{uid}',
  (event) => rankingController.recalculateLeagueRankings(event),
);

exports.weeklyReset = onSchedule(
  { schedule: '0 0 * * 1', timeZone: 'America/Sao_Paulo' },
  () => rankingController.weeklyReset(),
);

exports.onUserDeleted = functionsV1.auth
  .user()
  .onDelete((user) => rankingController.onUserDeleted(user));

// Firestore Trigger - Processa envio de e-mail ao criar documento em `mail`
exports.onMailCreated = onDocumentCreated('mail/{mailId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;
  await processMailDocument(snapshot);
});

// Firestore Trigger - Envia e-mail de boas-vindas ao criar novo usuário
exports.onUserCreated = onDocumentCreated('users/{userId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;
  await sendWelcomeEmail(event.params.userId);
});
