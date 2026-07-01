/* eslint-disable no-console */
const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore } = require('firebase-admin/firestore');
const { seedBlockAssemblyChallenges } = require('./block_assembly_seed.js');

const projectId = process.env.FIREBASE_PROJECT_ID || 'codequest-local';

if (!process.env.FIRESTORE_EMULATOR_HOST) {
  process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
}

if (!process.env.FIREBASE_AUTH_EMULATOR_HOST) {
  process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';
}

initializeApp({ projectId });

const auth = getAuth();
const db = getFirestore();

const seedUsers = [
  {
    uid: 'admin-001',
    email: 'admin@codequest.com',
    password: 'Dev@123456',
    displayName: 'Admin',
    xpTotal: 150,
    streakDays: 15,
    positionChange: 0,
  },
  {
    uid: 'dev-001',
    email: 'dev@codequest.com',
    password: 'Dev@123456',
    displayName: 'Dev User',
    xpTotal: 120,
    streakDays: 7,
    positionChange: 1,
  },
  {
    uid: 'dev-002',
    email: 'alice@codequest.com',
    password: 'Dev@123456',
    displayName: 'Alice',
    xpTotal: 100,
    streakDays: 7,
    positionChange: -1,
  },
  {
    uid: 'dev-003',
    email: 'bob@codequest.com',
    password: 'Dev@123456',
    displayName: 'Bob',
    xpTotal: 90,
    streakDays: 3,
    positionChange: 2,
  },
];

const bronzeLeagueId = 'bronze-001';
const trailId = 'flutter-basico';
const historyWeeks = 10;

const trailLevels = [
  { id: 'nivel-01', type: 'theory', title: 'Introducao ao Flutter', xpReward: 20, order: 1 },
  { id: 'nivel-02', type: 'quiz', title: 'Quiz de Widgets', xpReward: 25, order: 2 },
  { id: 'nivel-03', type: 'code', title: 'Pratica de Layout', xpReward: 30, order: 3 },
  { id: 'nivel-04', type: 'quiz', title: 'Quiz de Estado', xpReward: 25, order: 4 },
  { id: 'nivel-05', type: 'challenge', title: 'Desafio Final Basico', xpReward: 50, order: 5 },
];

const seedActivities = [
  {
    id: 'act-001',
    type: 'multipleChoice',
    question: 'Qual widget organiza filhos em coluna?',
    options: ['Row', 'Stack', 'Column', 'ListView'],
    correctAnswer: 'Column',
    hint: 'Pense em eixo vertical.',
    xpReward: 10,
    difficulty: 'easy',
    isActive: true,
  },
  {
    id: 'act-002',
    type: 'fillInBlank',
    question: 'Complete: setState(() { ___; })',
    options: [],
    correctAnswer: 'contador++',
    hint: 'Atualize um estado simples.',
    xpReward: 10,
    difficulty: 'easy',
    isActive: true,
  },
  {
    id: 'act-003',
    type: 'codeOrder',
    question: 'Ordene o fluxo para renderizar um app Flutter.',
    options: ['runApp(MyApp())', 'WidgetsFlutterBinding.ensureInitialized()', 'main()', 'build(context)'],
    correctAnswer: 'main() -> WidgetsFlutterBinding.ensureInitialized() -> runApp(MyApp()) -> build(context)',
    hint: 'Comeca no ponto de entrada do Dart.',
    xpReward: 15,
    difficulty: 'medium',
    isActive: true,
  },
];

async function upsertUser(user) {
  try {
    await auth.getUser(user.uid);
    await auth.updateUser(user.uid, {
      email: user.email,
      password: user.password,
      displayName: user.displayName,
    });
    console.log(`[seed] updated auth user ${user.uid}`);
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      await auth.createUser({
        uid: user.uid,
        email: user.email,
        password: user.password,
        displayName: user.displayName,
      });
      console.log(`[seed] created auth user ${user.uid}`);
    } else {
      throw error;
    }
  }
}

function mondayUtc(weeksAgo) {
  const now = new Date();
  const date = new Date(
    Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()),
  );
  const daysSinceMonday = (date.getUTCDay() + 6) % 7;
  date.setUTCDate(date.getUTCDate() - daysSinceMonday - weeksAgo * 7);
  return date;
}

function buildXpHistory(user, position) {
  const total = user.xpTotal || 0;
  let weightSum = 0;
  for (let i = 1; i <= historyWeeks; i += 1) {
    weightSum += i;
  }

  const entries = [];
  let cumulative = 0;
  for (let i = 0; i < historyWeeks; i += 1) {
    const weeksAgo = historyWeeks - 1 - i;
    let gain = Math.round((total * (i + 1)) / weightSum);
    if (i === historyWeeks - 1) {
      gain = total - cumulative;
    }
    cumulative += gain;
    const weekStart = mondayUtc(weeksAgo);
    entries.push({
      weekStartId: weekStart.toISOString().slice(0, 10),
      weekStart,
      xpTotal: cumulative,
      xpGained: gain,
      position,
      streakDays: Math.max(0, (user.streakDays || 0) - weeksAgo),
    });
  }
  return entries;
}

async function seed() {
  console.log('[seed] start');
  const now = new Date().toISOString();
  const leagueEndsAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

  const rankedUsers = [...seedUsers].sort((a, b) => b.xpTotal - a.xpTotal);
  const positionByUid = Object.fromEntries(
    rankedUsers.map((user, index) => [user.uid, index + 1]),
  );

  // 1. Seed Users com estado do jogo e histórico semanal.
  for (const user of seedUsers) {
    await upsertUser(user);
    await db.collection('users').doc(user.uid).set({
      uid: user.uid,
      email: user.email,
      name: user.displayName,
      displayName: user.displayName,
      leagueId: bronzeLeagueId,
      xpTotal: user.xpTotal,
      weeklyXp: user.xpTotal,
      streakDays: user.streakDays,
      position: positionByUid[user.uid],
      positionChange: user.positionChange,
      createdAt: now,
      updatedAt: now,
    }, { merge: true });

    const history = buildXpHistory(user, positionByUid[user.uid]);
    for (const entry of history) {
      await db
        .collection('users')
        .doc(user.uid)
        .collection('xpHistory')
        .doc(entry.weekStartId)
        .set({
          weekStart: entry.weekStart,
          xpTotal: entry.xpTotal,
          xpGained: entry.xpGained,
          position: entry.position,
          streakDays: entry.streakDays,
        }, { merge: true });
    }
  }

  // 2. Seed Leagues
  const leagueMembers = rankedUsers.map((user) => ({
    uid: user.uid,
    name: user.displayName,
    xpTotal: user.xpTotal,
    weeklyXp: user.xpTotal,
    position: positionByUid[user.uid],
    positionChange: user.positionChange,
  }));

  await db.collection('leagues').doc(bronzeLeagueId).set({
    id: bronzeLeagueId,
    name: 'Bronze',
    tier: 'bronze',
    promotionThreshold: 15,
    totalParticipants: leagueMembers.length,
    endsAt: leagueEndsAt,
    createdAt: now,
    updatedAt: now,
  }, { merge: true });

  for (const member of leagueMembers) {
    await db.collection('leagues').doc(bronzeLeagueId).collection('members').doc(member.uid).set({
      uid: member.uid,
      name: member.name,
      xpTotal: member.xpTotal,
      weeklyXp: member.weeklyXp,
      position: member.position,
      positionChange: member.positionChange,
      leagueId: bronzeLeagueId,
      createdAt: now,
      updatedAt: now,
    }, { merge: true });
  }

  // 3. Seed Trails
  await db.collection('trails').doc(trailId).set({
    id: trailId,
    title: 'Flutter Basico',
    language: 'Dart',
    description: 'Trilha introdutória aos conceitos fundamentais do Flutter.',
    totalLevels: trailLevels.length,
    createdAt: now,
    updatedAt: now,
  }, { merge: true });

  for (const level of trailLevels) {
    await db.collection('trails').doc(trailId).collection('levels').doc(level.id).set({
      ...level,
      isUnlocked: level.order === 1,
      isCompleted: false,
      stars: 0,
    }, { merge: true });
  }

  // 4. Seed Activities
  for (const activity of seedActivities) {
    await db.collection('activities').doc(activity.id).set({
      ...activity,
      createdAt: now,
      updatedAt: now,
    }, { merge: true });
  }

  // 5. Seed Meta
  await db.collection('meta').doc('seed').set({
    projectId,
    appliedAt: now,
    usersCount: seedUsers.length,
    trailId,
    leagueId: bronzeLeagueId,
    activitiesCount: seedActivities.length,
  }, { merge: true });

  // 6. Seed dos desafios de block assembly
  await seedBlockAssemblyChallenges(db);

  console.log('[seed] done');
}

seed()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('[seed] failed:', error);
    process.exit(1);
  });
