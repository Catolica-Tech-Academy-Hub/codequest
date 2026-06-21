/* eslint-disable no-console */
const { readFileSync } = require('node:fs');
const path = require('node:path');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const {
  JsonDefinitionsSource,
} = require('../functions/modules/achievements/definitions/json_definitions_source');

const projectId = process.env.FIREBASE_PROJECT_ID || 'codequest-local';

if (!process.env.FIRESTORE_EMULATOR_HOST) {
  process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
}

initializeApp({ projectId });

const db = getFirestore();

async function seedAchievements() {
  console.log('[seed:achievements] start');

  const raw = JSON.parse(
    readFileSync(path.join(__dirname, 'achievements.json'), 'utf8'),
  );

  // Valida o catálogo via mapper antes de gravar: config inválida falha o seed, não o runtime.
  const achievements = await new JsonDefinitionsSource({ entries: raw }).getAll();

  for (const achievement of achievements) {
    await db.collection('achievements').doc(achievement.id).set(achievement, { merge: true });
    console.log(`[seed:achievements] upserted ${achievement.id}`);
  }

  console.log(`[seed:achievements] done (${achievements.length})`);
}

seedAchievements()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('[seed:achievements] failed:', error);
    process.exit(1);
  });
