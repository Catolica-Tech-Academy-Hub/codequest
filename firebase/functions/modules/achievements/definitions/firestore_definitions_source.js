const { DefinitionsSource } = require('./definitions_source');
const { toAchievement } = require('./achievement_mapper');

class FirestoreDefinitionsSource extends DefinitionsSource {
  constructor({ db }) {
    super();
    this._collection = db.collection('achievements');
    // Cache de cold start: o catálogo é estático, então reusamos entre invocações
    // da mesma instância da function e evitamos uma leitura por verificação.
    this._cache = null;
  }

  async getAll() {
    if (this._cache) {
      return this._cache;
    }

    const snapshot = await this._collection.get();
    this._cache = snapshot.docs.map((doc) => toAchievement({ id: doc.id, ...doc.data() }));
    return this._cache;
  }
}

module.exports = {
  FirestoreDefinitionsSource,
};
