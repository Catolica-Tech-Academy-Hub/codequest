const { test } = require('node:test');
const assert = require('node:assert/strict');

const { GetPlayerStatsAction } = require('./get_player_stats_action');

function repoWith({ profile, ahead = 0 }) {
  return {
    async getUserProfile() {
      return profile;
    },
    async countAhead() {
      return ahead;
    },
  };
}

test('usa a posição persistida quando disponível', async () => {
  const action = new GetPlayerStatsAction(
    repoWith({
      profile: {
        userId: 'u1',
        xpTotal: 120,
        streakDays: 7,
        leagueId: 'bronze-001',
        position: 2,
        positionChange: 1,
      },
    }),
  );
  const result = await action.execute({ uid: 'u1' });
  assert.equal(result.position, 2);
  assert.equal(result.xpTotal, 120);
  assert.equal(result.streakDays, 7);
  assert.equal(result.positionChange, 1);
});

test('calcula a posição via countAhead quando position é nula', async () => {
  const action = new GetPlayerStatsAction(
    repoWith({
      profile: {
        userId: 'u1',
        xpTotal: 90,
        streakDays: 3,
        leagueId: 'bronze-001',
        position: null,
        positionChange: 0,
      },
      ahead: 3,
    }),
  );
  const result = await action.execute({ uid: 'u1' });
  assert.equal(result.position, 4); // 3 à frente + 1
});

test('lança quando o perfil não existe', async () => {
  const action = new GetPlayerStatsAction(repoWith({ profile: null }));
  await assert.rejects(() => action.execute({ uid: 'x' }), /não encontrado/i);
});

test('lança quando uid está ausente', async () => {
  const action = new GetPlayerStatsAction(repoWith({ profile: null }));
  await assert.rejects(() => action.execute({}), /uid/i);
});
