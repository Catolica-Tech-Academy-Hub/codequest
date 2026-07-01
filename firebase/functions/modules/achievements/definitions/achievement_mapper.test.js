const { test } = require('node:test');
const assert = require('node:assert/strict');

const { toAchievement } = require('./achievement_mapper');

function validRaw(overrides = {}) {
  return {
    id: 'first-steps',
    name: 'Primeiros Passos',
    description: 'Acumule seus primeiros 100 XP.',
    iconKey: 'footprints',
    tier: 'common',
    category: 'xp',
    condition: { field: 'xpTotal', operator: '>=', value: 100 },
    ...overrides,
  };
}

test('mapeia um catálogo cru válido para o domínio', () => {
  const achievement = toAchievement(validRaw());

  assert.equal(achievement.id, 'first-steps');
  assert.equal(achievement.name, 'Primeiros Passos');
  assert.equal(achievement.tier, 'common');
  assert.equal(achievement.category, 'xp');
  assert.deepEqual(achievement.condition, {
    field: 'xpTotal',
    operator: '>=',
    value: 100,
  });
});

test('rejeita id ausente ou vazio', () => {
  assert.throws(() => toAchievement(validRaw({ id: '' })), /id/i);
  assert.throws(() => toAchievement(validRaw({ id: undefined })), /id/i);
});

test('rejeita campos textuais obrigatórios ausentes', () => {
  assert.throws(() => toAchievement(validRaw({ name: '' })), /name/i);
  assert.throws(() => toAchievement(validRaw({ description: '' })), /description/i);
  assert.throws(() => toAchievement(validRaw({ iconKey: '' })), /iconKey/i);
  assert.throws(() => toAchievement(validRaw({ category: '' })), /category/i);
});

test('rejeita tier fora do conjunto suportado', () => {
  assert.throws(() => toAchievement(validRaw({ tier: 'mitico' })), /tier/i);
});

test('rejeita condição sem campo', () => {
  assert.throws(
    () => toAchievement(validRaw({ condition: { operator: '>=', value: 100 } })),
    /field/i,
  );
});

test('rejeita operador não suportado na condição', () => {
  assert.throws(
    () => toAchievement(validRaw({ condition: { field: 'xpTotal', operator: '~=', value: 100 } })),
    /operador/i,
  );
});

test('rejeita valor não numérico na condição', () => {
  assert.throws(
    () => toAchievement(validRaw({ condition: { field: 'xpTotal', operator: '>=', value: '100' } })),
    /value/i,
  );
});
