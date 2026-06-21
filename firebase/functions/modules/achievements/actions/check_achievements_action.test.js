const { test } = require('node:test');
const assert = require('node:assert/strict');

const { CheckAchievementsAction } = require('./check_achievements_action');

function achievement(id, condition) {
  return {
    id,
    name: id,
    description: id,
    iconKey: id,
    tier: 'common',
    category: 'xp',
    condition,
  };
}

function buildAction({ definitions, stats, unlocked = [] }) {
  const unlockCalls = [];
  const definitionsSource = {
    getAll: async () => definitions,
  };
  const repository = {
    getUserStats: async () => stats,
    getUnlockedIds: async () => new Set(unlocked),
    unlock: async (uid, id) => {
      unlockCalls.push({ uid, id });
    },
  };
  const action = new CheckAchievementsAction({ definitionsSource, repository });
  return { action, unlockCalls };
}

test('desbloqueia conquistas cuja condição é satisfeita', async () => {
  const { action, unlockCalls } = buildAction({
    definitions: [
      achievement('xp-100', { field: 'xpTotal', operator: '>=', value: 100 }),
      achievement('streak-7', { field: 'streak', operator: '>=', value: 7 }),
    ],
    stats: { xpTotal: 150, streak: 3 },
  });

  const result = await action.execute('user-1');

  assert.deepEqual(result.unlocked.map((a) => a.id), ['xp-100']);
  assert.deepEqual(unlockCalls, [{ uid: 'user-1', id: 'xp-100' }]);
});

test('retorna o objeto da conquista (sem a condição) para o front exibir', async () => {
  const { action } = buildAction({
    definitions: [achievement('xp-100', { field: 'xpTotal', operator: '>=', value: 100 })],
    stats: { xpTotal: 150, streak: 0 },
  });

  const result = await action.execute('user-1');

  assert.deepEqual(result.unlocked, [
    {
      id: 'xp-100',
      name: 'xp-100',
      description: 'xp-100',
      iconKey: 'xp-100',
      tier: 'common',
      category: 'xp',
    },
  ]);
});

test('não reavalia nem repersiste conquistas já desbloqueadas (dedup)', async () => {
  const { action, unlockCalls } = buildAction({
    definitions: [achievement('xp-100', { field: 'xpTotal', operator: '>=', value: 100 })],
    stats: { xpTotal: 150, streak: 0 },
    unlocked: ['xp-100'],
  });

  const result = await action.execute('user-1');

  assert.deepEqual(result.unlocked, []);
  assert.equal(unlockCalls.length, 0);
});

test('não desbloqueia quando nenhuma condição é satisfeita', async () => {
  const { action, unlockCalls } = buildAction({
    definitions: [achievement('xp-500', { field: 'xpTotal', operator: '>=', value: 500 })],
    stats: { xpTotal: 100, streak: 0 },
  });

  const result = await action.execute('user-1');

  assert.deepEqual(result.unlocked, []);
  assert.equal(unlockCalls.length, 0);
});

test('desbloqueia múltiplas conquistas de uma vez', async () => {
  const { action, unlockCalls } = buildAction({
    definitions: [
      achievement('xp-100', { field: 'xpTotal', operator: '>=', value: 100 }),
      achievement('streak-7', { field: 'streak', operator: '>=', value: 7 }),
      achievement('xp-500', { field: 'xpTotal', operator: '>=', value: 500 }),
    ],
    stats: { xpTotal: 150, streak: 10 },
  });

  const result = await action.execute('user-1');

  assert.deepEqual(result.unlocked.map((a) => a.id).sort(), ['streak-7', 'xp-100']);
  assert.equal(unlockCalls.length, 2);
});
