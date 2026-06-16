const admin = require('firebase-admin');

class SampleRepository {
  constructor() {
    this._db = admin.firestore();
    this._collection = this._db.collection('sampleItems');
  }

  async create({ title }) {
    const ref = this._collection.doc();
    const payload = {
      title,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await ref.set(payload);

    return {
      id: ref.id,
      ...payload,
    };
  }

  async list() {
    const snapshot = await this._collection.orderBy('createdAt', 'desc').get();
    return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  }
}

module.exports = {
  SampleRepository,
};
