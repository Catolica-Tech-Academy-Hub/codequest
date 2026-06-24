const admin = require('firebase-admin');
const { onRequest, onCall, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { createSampleModule } = require('./modules/sample');
const { createAchievementsModule } = require('./modules/achievements');
const { processLeagueCycle } = require('./modules/leagues');

admin.initializeApp();

const sampleController = createSampleModule();
const checkAchievementsAction = createAchievementsModule();

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

// Pub/Sub Trigger - Ciclo Semanal das Ligas
// Executa todo domingo às 23:59
exports.weeklyLeagueCycle = onSchedule("59 23 * * 0", async (event) => {
  console.log("Iniciando rotina semanal do sistema de ligas...");
  await processLeagueCycle();
});
