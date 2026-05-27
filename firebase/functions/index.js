const admin = require('firebase-admin');
const { onRequest, onCall } = require('firebase-functions/v2/https');
const { createSampleModule } = require('./modules/sample');
const { createUserModule } = require('./modules/user');

admin.initializeApp();

const sampleController = createSampleModule();
const userController = createUserModule();

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

// RF04 / RF07 — Atualização de perfil (nome, bio)
exports.updateUserProfile = onCall(userController.updateProfile);

// RF16 — Preferências de notificação
exports.updateUserNotifications = onCall(userController.updateNotifications);

// RF08 — Exclusão de conta (atomicamente: Firestore + Auth)
exports.deleteUserAccount = onCall(userController.deleteAccount);

