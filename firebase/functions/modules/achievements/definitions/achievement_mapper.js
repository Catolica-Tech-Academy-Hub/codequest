const { isSupportedOperator } = require('../domain/evaluate_condition');

const TIERS = ['common', 'rare', 'epic', 'legendary'];

function requireText(raw, key) {
  const value = raw[key];
  if (typeof value !== 'string' || value.trim() === '') {
    throw new Error(`Conquista inválida: "${key}" é obrigatório.`);
  }
  return value.trim();
}

function toCondition(raw) {
  if (!raw || typeof raw !== 'object') {
    throw new Error('Conquista inválida: "condition" é obrigatório.');
  }

  const field = requireText(raw, 'field');

  if (!isSupportedOperator(raw.operator)) {
    throw new Error(`Conquista inválida: operador não suportado "${raw.operator}".`);
  }

  if (typeof raw.value !== 'number' || Number.isNaN(raw.value)) {
    throw new Error('Conquista inválida: "value" da condição deve ser numérico.');
  }

  return { field, operator: raw.operator, value: raw.value };
}

function toAchievement(raw) {
  if (!raw || typeof raw !== 'object') {
    throw new Error('Conquista inválida: definição ausente.');
  }

  const tier = requireText(raw, 'tier');
  if (!TIERS.includes(tier)) {
    throw new Error(`Conquista inválida: tier desconhecido "${tier}".`);
  }

  return {
    id: requireText(raw, 'id'),
    name: requireText(raw, 'name'),
    description: requireText(raw, 'description'),
    iconKey: requireText(raw, 'iconKey'),
    tier,
    category: requireText(raw, 'category'),
    condition: toCondition(raw.condition),
  };
}

module.exports = {
  toAchievement,
  TIERS,
};
