const { test } = require('node:test');
const assert = require('node:assert/strict');

const { WeeklyResetAction } = require('./weekly_reset_action');

function fakeRepo(users) {
  return {
    written: null,
    userUpdates: [],
    async listLeagues() {
      return [{ id: 'bronze-001', tier: 'bronze' }];
    },
    // Sem liga acima/abaixo: mantém o teste focado no snapshot/reset.
    async findLeagueIdByTier() {
      return null;
    },
    async listLeagueUsersByWeeklyXp() {
      return users;
    },
    async moveMember() {},
    async commitUserUpdates(updates) {
      this.userUpdates.push(...updates);
    },
    async writeXpHistorySnapshots(snapshots) {
      this.written = snapshots;
    },
  };
}

test('grava snapshot semanal com xpGained = weeklyXp antes de zerar', async () => {
  const users = [
    {
      id: 'dev-001',
      xpTotal: 120,
      weeklyXp: 45,
      position: 2,
      streakDays: 7,
      displayName: 'Dev',
    },
    {
      id: 'dev-002',
      xpTotal: 100,
      weeklyXp: 30,
      position: 3,
      streakDays: 5,
      displayName: 'Alice',
    },
  ];
  const repo = fakeRepo(users);
  const action = new WeeklyResetAction(repo);

  const result = await action.execute();

  assert.equal(repo.written.length, 2);
  const s1 = repo.written.find((s) => s.uid === 'dev-001');
  assert.equal(s1.data.xpGained, 45); // = weeklyXp da semana
  assert.equal(s1.data.xpTotal, 120);
  assert.equal(s1.data.position, 2);
  assert.equal(s1.data.streakDays, 7);
  assert.match(s1.weekStartId, /^\d{4}-\d{2}-\d{2}$/);
  assert.ok(s1.data.weekStart instanceof Date);

  assert.equal(result.snapshots, 2);
  // Reset aplicado a todos.
  assert.ok(repo.userUpdates.every((u) => u.data.weeklyXp === 0));
});

test('usa o índice como posição quando position está ausente', async () => {
  const users = [
    { id: 'a', xpTotal: 50, weeklyXp: 10, streakDays: 1 },
    { id: 'b', xpTotal: 40, weeklyXp: 5, streakDays: 0 },
  ];
  const repo = fakeRepo(users);
  await new WeeklyResetAction(repo).execute();

  assert.equal(repo.written.find((s) => s.uid === 'a').data.position, 1);
  assert.equal(repo.written.find((s) => s.uid === 'b').data.position, 2);
});
