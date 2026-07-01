const OPERATORS = {
  '>=': (actual, target) => actual >= target,
  '>': (actual, target) => actual > target,
  '<=': (actual, target) => actual <= target,
  '<': (actual, target) => actual < target,
  '==': (actual, target) => actual === target,
};

function isSupportedOperator(operator) {
  return Object.prototype.hasOwnProperty.call(OPERATORS, operator);
}

function evaluateCondition(condition, stats) {
  const apply = OPERATORS[condition.operator];
  if (!apply) {
    throw new Error(`Operador não suportado: ${condition.operator}`);
  }

  const actual = stats[condition.field];
  if (typeof actual !== 'number') {
    return false;
  }

  return apply(actual, condition.value);
}

module.exports = {
  evaluateCondition,
  isSupportedOperator,
};
