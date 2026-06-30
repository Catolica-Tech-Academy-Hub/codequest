const admin = require('firebase-admin');

class UserRepository {
  constructor() {
    this._db = admin.firestore();
    this._collection = this._db.collection('users');
  }

  async getById(uid) {
    const doc = await this._collection.doc(uid).get();
    if (!doc.exists) return null;
    return { id: doc.id, ...doc.data() };
  }

  async update(uid, { name, bio }) {
    await this._collection.doc(uid).update({ name, bio: bio ?? null });
  }

  async updateNotifications(uid, enabled) {
    await this._collection.doc(uid).update({ notificationsEnabled: enabled });
  }

  async setDeactivated(uid, value) {
    await this._collection.doc(uid).update({ isDeactivated: value });
  }

  async delete(uid) {
    await this._collection.doc(uid).delete();
  }
}

module.exports = { UserRepository };
