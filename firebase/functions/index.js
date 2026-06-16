const admin = require('firebase-admin');
const { onRequest } = require('firebase-functions/v2/https');
const {
  onDocumentCreated,
  onDocumentWritten,
} = require('firebase-functions/v2/firestore');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const functionsV1 = require('firebase-functions/v1');
const { createSampleModule } = require('./modules/sample');
const { createRankingModule } = require('./modules/ranking');

admin.initializeApp();

const sampleController = createSampleModule();
const rankingController = createRankingModule();

exports.health = onRequest((request, response) => {
  response.status(200).json({
    status: 'ok',
    service: 'codequest-functions',
    timestamp: new Date().toISOString(),
  });
});

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

