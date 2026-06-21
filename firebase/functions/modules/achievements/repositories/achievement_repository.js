const { FieldValue } = require('firebase-admin/firestore');

class AchievementRepository {
  constructor({ db }) {
    this._db = db;
    this._users = db.collection('users');
  }

  async getUserStats(uid) {
    const snapshot = await this._users.doc(uid).get();
    const data = snapshot.data() || {};

    // Tradução de nomes no boundary: o Firestore guarda `streakDays`, o domínio fala `streak`.
    return {
      xpTotal: typeof data.xpTotal === 'number' ? data.xpTotal : 0,
      streak: typeof data.streakDays === 'number' ? data.streakDays : 0,
    };
  }

  async getUnlockedIds(uid) {
    const snapshot = await this._users.doc(uid).collection('achievements').get();
    return new Set(snapshot.docs.map((doc) => doc.id));
  }

  async unlock(uid, achievementId) {
    // doc.id = id da conquista torna o registro idempotente.
    await this._users
      .doc(uid)
      .collection('achievements')
      .doc(achievementId)
      .set(
        { unlockedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
  }
}

module.exports = {
  AchievementRepository,
};
