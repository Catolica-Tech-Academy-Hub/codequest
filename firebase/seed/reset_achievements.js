/* eslint-disable no-console */
// Uso (contra o emulador):
//   node reset_achievements.js <uid> [achievementId]
// Sem achievementId, limpa TODOS os desbloqueios do usuário.
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

if (!process.env.FIRESTORE_EMULATOR_HOST) {
  process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
}

initializeApp({ projectId: process.env.FIREBASE_PROJECT_ID || 'codequest-local' });
const db = getFirestore();

const [uid, achievementId] = process.argv.slice(2);

async function run() {
  if (!uid) {
    throw new Error('Informe o uid: node reset_achievements.js <uid> [achievementId]');
  }

  const col = db.collection('users').doc(uid).collection('achievements');

  if (achievementId) {
    await col.doc(achievementId).delete();
    console.log(`[reset] removido ${uid}/${achievementId}`);
    return;
  }

  const snapshot = await col.get();
  await Promise.all(snapshot.docs.map((doc) => doc.ref.delete()));
  console.log(`[reset] removidos ${snapshot.size} desbloqueios de ${uid}`);
}

run()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('[reset] failed:', error.message);
    process.exit(1);
  });
