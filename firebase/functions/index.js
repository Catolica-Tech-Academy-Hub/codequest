const admin = require('firebase-admin');
const { onRequest, onCall } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { createSampleModule } = require('./modules/sample');
const { createUserModule } = require('./modules/user');
const { processLeagueCycle } = require('./modules/leagues');
const { processMailDocument, sendWelcomeEmail } = require('./modules/notifications');

admin.initializeApp();

const sampleController = createSampleModule();
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

exports.updateUserProfile = onCall(userController.updateProfile);

exports.updateUserNotifications = onCall(userController.updateNotifications);

exports.deleteUserAccount = onCall(userController.deleteAccount);

// Pub/Sub Trigger - Ciclo Semanal das Ligas
// Executa todo domingo às 23:59
exports.weeklyLeagueCycle = onSchedule("59 23 * * 0", async (event) => {
  console.log("Iniciando rotina semanal do sistema de ligas...");
  await processLeagueCycle();
});

// Firestore Trigger - Processa envio de e-mail ao criar documento em `mail`
exports.onMailCreated = onDocumentCreated("mail/{mailId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;
  await processMailDocument(snapshot);
});

// Firestore Trigger - Envia e-mail de boas-vindas ao criar novo usuário
exports.onUserCreated = onDocumentCreated("users/{userId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;
  await sendWelcomeEmail(event.params.userId);
});
