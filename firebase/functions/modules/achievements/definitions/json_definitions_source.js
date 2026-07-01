const { DefinitionsSource } = require('./definitions_source');
const { toAchievement } = require('./achievement_mapper');

class JsonDefinitionsSource extends DefinitionsSource {
  constructor({ entries }) {
    super();
    this._entries = entries;
  }

  async getAll() {
    return this._entries.map((entry) => toAchievement(entry));
  }
}

module.exports = {
  JsonDefinitionsSource,
};
