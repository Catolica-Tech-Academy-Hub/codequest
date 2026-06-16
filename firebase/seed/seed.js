/* eslint-disable no-console */
const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore } = require('firebase-admin/firestore');

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
    streakDays: 5,
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

const trailLevels = [
  {
    id: 'nivel-01',
    type: 'theory',
    title: 'Introducao ao Flutter',
    xpReward: 20,
    order: 1,
  },
  {
    id: 'nivel-02',
    type: 'quiz',
    title: 'Quiz de Widgets',
    xpReward: 25,
    order: 2,
  },
  {
    id: 'nivel-03',
    type: 'code',
    title: 'Pratica de Layout',
    xpReward: 30,
    order: 3,
  },
  {
    id: 'nivel-04',
    type: 'quiz',
    title: 'Quiz de Estado',
    xpReward: 25,
    order: 4,
  },
  {
    id: 'nivel-05',
    type: 'challenge',
    title: 'Desafio Final Basico',
    xpReward: 50,
    order: 5,
  },
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
  },
  {
    id: 'act-002',
    type: 'fillInBlank',
    question: 'Complete: setState(() { ___; })',
    options: [],
    correctAnswer: 'contador++',
    hint: 'Atualize um estado simples.',
    xpReward: 10,
  },
  {
    id: 'act-003',
    type: 'codeOrder',
    question: 'Ordene o fluxo para renderizar um app Flutter.',
    options: [
      'runApp(MyApp())',
      'WidgetsFlutterBinding.ensureInitialized()',
      'main()',
      'build(context)',
    ],
    correctAnswer:
      'main() -> WidgetsFlutterBinding.ensureInitialized() -> runApp(MyApp()) -> build(context)',
    hint: 'Comeca no ponto de entrada do Dart.',
    xpReward: 15,
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

async function seed() {
  console.log('[seed] start');

  for (const user of seedUsers) {
    await upsertUser(user);
    await db.collection('users').doc(user.uid).set(
      {
        uid: user.uid,
        email: user.email,
        name: user.displayName,
        displayName: user.displayName,
        leagueId: bronzeLeagueId,
        xpTotal: user.xpTotal,
        streakDays: user.streakDays,
        positionChange: user.positionChange,
        updatedAt: new Date().toISOString(),
      },
      { merge: true },
    );
  }

  await db.collection('leagues').doc(bronzeLeagueId).set(
    {
      id: bronzeLeagueId,
      name: 'Bronze',
      // tier como String e endsAt como Date (vira Timestamp): formato exigido pela leitura no app.
      tier: 'bronze',
      endsAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      promotionThreshold: 15,
      totalParticipants: seedUsers.length,
      createdAt: new Date().toISOString(),
    },
    { merge: true },
  );

  const leagueMembers = [
    { uid: 'dev-001', name: 'Dev User', xp: 120, weeklyXp: 45 },
    { uid: 'dev-002', name: 'Alice', xp: 100, weeklyXp: 30 },
    { uid: 'dev-003', name: 'Bob', xp: 90, weeklyXp: 25 },
  ];

  for (let index = 0; index < leagueMembers.length; index += 1) {
    const member = leagueMembers[index];
    await db
      .collection('leagues')
      .doc(bronzeLeagueId)
      .collection('members')
      .doc(member.uid)
      .set(
        {
          uid: member.uid,
          name: member.name,
          xp: member.xp,
          weeklyXp: member.weeklyXp,
          position: index + 1,
          deltaPosition: 0,
          leagueId: bronzeLeagueId,
          updatedAt: new Date().toISOString(),
        },
        { merge: true },
      );
  }

  await db.collection('trails').doc(trailId).set(
    {
      id: trailId,
      title: 'Flutter Basico',
      language: 'Dart',
      totalLevels: trailLevels.length,
      createdAt: new Date().toISOString(),
    },
    { merge: true },
  );

  for (const level of trailLevels) {
    await db
      .collection('trails')
      .doc(trailId)
      .collection('levels')
      .doc(level.id)
      .set(
        {
          ...level,
          isUnlocked: level.order === 1,
          isCompleted: false,
          stars: 0,
        },
        { merge: true },
      );
  }

  for (const activity of seedActivities) {
    await db.collection('activities').doc(activity.id).set(activity, { merge: true });
  }

  await db.collection('meta').doc('seed').set(
    {
      projectId,
      appliedAt: new Date().toISOString(),
      usersCount: seedUsers.length,
      trailId,
      leagueId: bronzeLeagueId,
      activitiesCount: seedActivities.length,
    },
    { merge: true },
  );

  console.log('[seed] done');
}

seed()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('[seed] failed:', error);
    process.exit(1);
  });

