const admin = require('firebase-admin');
const { onRequest, onCall, HttpsError } = require('firebase-functions/v2/https');
const {
  onDocumentCreated,
  onDocumentWritten,
} = require('firebase-functions/v2/firestore');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const functionsV1 = require('firebase-functions/v1');
const { createSampleModule } = require('./modules/sample');
const { createAchievementsModule } = require('./modules/achievements');
const { createRankingModule } = require('./modules/ranking');

admin.initializeApp();

const sampleController = createSampleModule();
const checkAchievementsAction = createAchievementsModule();
const rankingController = createRankingModule();

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

// Callable - Motor de conquistas (BE07)
exports.checkAchievements = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Necessário estar autenticado.');
  }

  return checkAchievementsAction.execute(uid);
});

// Firestore/Scheduler Triggers - Ranking e ciclo semanal das ligas (evolucao-xp).
// O weeklyReset substitui o antigo weeklyLeagueCycle (modules/leagues): ambos
// faziam promoção/rebaixamento/reset; manter os dois processaria a liga em
// duplicidade.
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
