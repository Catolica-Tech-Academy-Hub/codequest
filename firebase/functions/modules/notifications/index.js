const admin = require('firebase-admin');
const { welcomeEmail, leaguePromotionEmail } = require('./email_templates');

async function processMailDocument(snapshot) {
  const mailData = snapshot.data();
  const { to, template, data } = mailData;

  if (!to || !template) {
    console.error('Mail: documento inválido, faltam campos "to" ou "template"');
    await snapshot.ref.update({ status: 'error', error: 'Campos obrigatórios ausentes' });
    return;
  }

  let emailContent;
  switch (template) {
    case 'welcome':
      emailContent = welcomeEmail(data?.userName || 'Aluno');
      break;
    case 'league_promotion':
      emailContent = leaguePromotionEmail(
        data?.userName || 'Aluno',
        data?.oldTier || 'bronze',
        data?.newTier || 'silver',
      );
      break;
    default:
      console.warn(`Mail: template desconhecido "${template}"`);
      await snapshot.ref.update({ status: 'error', error: `Template "${template}" não encontrado` });
      return;
  }

  console.log(`=== E-MAIL ENVIADO ===`);
  console.log(`Para: ${to}`);
  console.log(`Assunto: ${emailContent.subject}`);
  console.log(`Template: ${template}`);
  console.log(`======================`);

  await snapshot.ref.update({
    status: 'sent',
    sentAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function createPromotionNotification(userId, oldTier, newTier) {
  const db = admin.firestore();

  const userDoc = await db.collection('users').doc(userId).get();
  const userData = userDoc.data() || {};
  const prefs = userData.notificationPreferences || {};

  if (prefs.promotionAlertsEnabled !== false && prefs.pushEnabled !== false) {
    await db.collection('users').doc(userId).collection('notifications').add({
      type: 'league_promotion',
      oldTier,
      newTier,
      seen: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  if (prefs.emailEnabled !== false && userData.email) {
    await db.collection('mail').add({
      to: userData.email,
      template: 'league_promotion',
      data: {
        userName: userData.name || userData.displayName || 'Aluno',
        oldTier,
        newTier,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  if (prefs.pushEnabled !== false && prefs.promotionAlertsEnabled !== false) {
    const tokens = userData.fcmTokens || [];
    const tierLabels = { silver: 'Prata', gold: 'Ouro', diamond: 'Diamante' };
    const newLabel = tierLabels[newTier] || newTier;

    for (const token of tokens) {
      try {
        await admin.messaging().send({
          token,
          notification: {
            title: 'Parabéns! Você foi promovido! 🏆',
            body: `Você subiu para a liga ${newLabel}!`,
          },
          data: {
            route: '/home/ranking',
            type: 'league_promotion',
          },
        });
      } catch (err) {
        if (err.code === 'messaging/registration-token-not-registered') {
          await db.collection('users').doc(userId).update({
            fcmTokens: admin.firestore.FieldValue.arrayRemove([token]),
          });
        }
        console.warn(`FCM: Falha ao enviar para token: ${err.message}`);
      }
    }
  }
}

async function sendWelcomeEmail(userId) {
  const db = admin.firestore();
  const userDoc = await db.collection('users').doc(userId).get();

  if (!userDoc.exists) return;

  const userData = userDoc.data();
  const prefs = userData.notificationPreferences || {};

  if (prefs.emailEnabled === false) return;
  if (!userData.email) return;

  await db.collection('mail').add({
    to: userData.email,
    template: 'welcome',
    data: {
      userName: userData.name || userData.displayName || 'Aluno',
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

module.exports = {
  processMailDocument,
  createPromotionNotification,
  sendWelcomeEmail,
};
