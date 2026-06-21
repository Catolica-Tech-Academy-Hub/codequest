const admin = require('firebase-admin');
const { onRequest, onCall, HttpsError } = require('firebase-functions/v2/https');
const { createSampleModule } = require('./modules/sample');
const { createAchievementsModule } = require('./modules/achievements');

admin.initializeApp();

const sampleController = createSampleModule();
const checkAchievementsAction = createAchievementsModule();

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

exports.checkAchievements = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Necessário estar autenticado.');
  }

  return checkAchievementsAction.execute(uid);
});

