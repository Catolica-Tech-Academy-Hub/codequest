const { test } = require('node:test');
const assert = require('node:assert/strict');

const {
  GetXpHistoryAction,
  DEFAULT_WEEKS,
  MAX_WEEKS,
} = require('./get_xp_history_action');

function repoCapturing() {
  const calls = [];
  return {
    calls,
    async listXpHistory(args) {
      calls.push(args);
      return [
        {
          weekStart: '2026-06-22T00:00:00.000Z',
          xpTotal: 120,
          xpGained: 22,
          position: 2,
          streakDays: 7,
        },
      ];
    },
  };
}

test('usa DEFAULT_WEEKS quando weeks é ausente ou inválido', async () => {
  const repo = repoCapturing();
  const action = new GetXpHistoryAction(repo);
  await action.execute({ uid: 'u1' });
  assert.equal(repo.calls[0].weeks, DEFAULT_WEEKS);
  await action.execute({ uid: 'u1', weeks: 'abc' });
  assert.equal(repo.calls[1].weeks, DEFAULT_WEEKS);
});

test('clampa weeks entre 1 e MAX_WEEKS', async () => {
  const repo = repoCapturing();
  const action = new GetXpHistoryAction(repo);
  await action.execute({ uid: 'u1', weeks: 0 });
  assert.equal(repo.calls[0].weeks, 1);
  await action.execute({ uid: 'u1', weeks: 999 });
  assert.equal(repo.calls[1].weeks, MAX_WEEKS);
});

test('retorna as entradas do repositório sob a chave entries', async () => {
  const action = new GetXpHistoryAction(repoCapturing());
  const result = await action.execute({ uid: 'u1', weeks: 4 });
  assert.equal(result.entries.length, 1);
  assert.equal(result.entries[0].xpTotal, 120);
});

test('lança quando uid está ausente', async () => {
  const action = new GetXpHistoryAction(repoCapturing());
  await assert.rejects(() => action.execute({}), /uid/i);
});
