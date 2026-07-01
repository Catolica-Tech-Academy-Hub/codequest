const { test } = require('node:test');
const assert = require('node:assert/strict');

const { evaluateCondition } = require('./evaluate_condition');

test('satisfaz quando o valor do stat atinge a meta (>=)', () => {
  const condition = { field: 'xpTotal', operator: '>=', value: 100 };
  assert.equal(evaluateCondition(condition, { xpTotal: 100 }), true);
  assert.equal(evaluateCondition(condition, { xpTotal: 150 }), true);
});

test('não satisfaz quando o valor fica abaixo da meta (>=)', () => {
  const condition = { field: 'xpTotal', operator: '>=', value: 100 };
  assert.equal(evaluateCondition(condition, { xpTotal: 99 }), false);
});

test('suporta os operadores de comparação', () => {
  const stats = { streak: 7 };
  assert.equal(evaluateCondition({ field: 'streak', operator: '>', value: 6 }, stats), true);
  assert.equal(evaluateCondition({ field: 'streak', operator: '>', value: 7 }, stats), false);
  assert.equal(evaluateCondition({ field: 'streak', operator: '<', value: 8 }, stats), true);
  assert.equal(evaluateCondition({ field: 'streak', operator: '<=', value: 7 }, stats), true);
  assert.equal(evaluateCondition({ field: 'streak', operator: '==', value: 7 }, stats), true);
  assert.equal(evaluateCondition({ field: 'streak', operator: '==', value: 6 }, stats), false);
});

test('não satisfaz quando o campo não existe nos stats', () => {
  const condition = { field: 'streak', operator: '>=', value: 7 };
  assert.equal(evaluateCondition(condition, { xpTotal: 500 }), false);
});

test('não satisfaz quando o campo não é numérico', () => {
  const condition = { field: 'xpTotal', operator: '>=', value: 100 };
  assert.equal(evaluateCondition(condition, { xpTotal: null }), false);
  assert.equal(evaluateCondition(condition, { xpTotal: 'muito' }), false);
});

test('rejeita operador não suportado (erro de configuração)', () => {
  const condition = { field: 'xpTotal', operator: '~=', value: 100 };
  assert.throws(() => evaluateCondition(condition, { xpTotal: 100 }), /operador/i);
});
