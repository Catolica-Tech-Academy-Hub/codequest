const admin = require('firebase-admin');
const { onRequest } = require('firebase-functions/v2/https');
const { createSampleModule } = require('./modules/sample');

admin.initializeApp();

const sampleController = createSampleModule();

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

