const admin = require('firebase-admin');

class RankingRepository {
  constructor() {
    this._db = admin.firestore();
  }

  _userDoc(uid) {
    return this._db.collection('users').doc(uid);
  }

  _memberDoc(leagueId, uid) {
    return this._db
      .collection('leagues')
      .doc(leagueId)
      .collection('members')
      .doc(uid);
  }

  async getUser(uid) {
    const snap = await this._userDoc(uid).get();
    if (!snap.exists) {
      return null;
    }
    return { id: snap.id, ...snap.data() };
  }

  async incrementUserWeeklyXp(uid, amount) {
    await this._userDoc(uid).set(
      {
        weeklyXp: admin.firestore.FieldValue.increment(amount),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }

  async syncLeagueMember({ leagueId, uid, name, xpTotal, awardedXp }) {
    await this._memberDoc(leagueId, uid).set(
      {
        uid,
        name,
        leagueId,
        xp: xpTotal,
        weeklyXp: admin.firestore.FieldValue.increment(awardedXp),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }

  async listLeagueUsersByXp(leagueId) {
    const snapshot = await this._db
      .collection('users')
      .where('leagueId', '==', leagueId)
      .orderBy('xpTotal', 'desc')
      .get();
    return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  }

  async listLeagueUsersByWeeklyXp(leagueId) {
    const snapshot = await this._db
      .collection('users')
      .where('leagueId', '==', leagueId)
      .orderBy('weeklyXp', 'desc')
      .get();
    return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  }

  async listLeagues() {
    const snapshot = await this._db.collection('leagues').get();
    return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  }

  async findLeagueIdByTier(tier) {
    const snapshot = await this._db
      .collection('leagues')
      .where('tier', '==', tier)
      .limit(1)
      .get();
    if (snapshot.empty) {
      return null;
    }
    return snapshot.docs[0].id;
  }

  async commitUserUpdates(updates) {
    if (updates.length === 0) {
      return;
    }
    const batch = this._db.batch();
    for (const update of updates) {
      batch.set(this._userDoc(update.uid), update.data, { merge: true });
    }
    await batch.commit();
  }

  async commitMemberUpdates(updates) {
    if (updates.length === 0) {
      return;
    }
    const batch = this._db.batch();
    for (const update of updates) {
      batch.set(this._memberDoc(update.leagueId, update.uid), update.data, {
        merge: true,
      });
    }
    await batch.commit();
  }

  async moveMember({ uid, name, fromLeagueId, toLeagueId, xp }) {
    const batch = this._db.batch();
    if (fromLeagueId && fromLeagueId !== toLeagueId) {
      batch.delete(this._memberDoc(fromLeagueId, uid));
    }
    batch.set(
      this._memberDoc(toLeagueId, uid),
      {
        uid,
        name,
        leagueId: toLeagueId,
        xp,
        weeklyXp: 0,
        deltaPosition: 0,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    await batch.commit();
  }

  /**
   * Grava os snapshots semanais de XP em `users/{uid}/xpHistory/{weekStartId}`.
   * doc.id = data do início da semana torna a escrita idempotente (re-rodar o
   * reset não duplica a semana). Commita em lotes para respeitar o limite do batch.
   */
  async writeXpHistorySnapshots(snapshots) {
    if (!snapshots || snapshots.length === 0) {
      return;
    }
    let batch = this._db.batch();
    let operations = 0;
    for (const snapshot of snapshots) {
      const ref = this._userDoc(snapshot.uid)
        .collection('xpHistory')
        .doc(snapshot.weekStartId);
      batch.set(ref, snapshot.data, { merge: true });
      operations += 1;
      if (operations >= 400) {
        await batch.commit();
        batch = this._db.batch();
        operations = 0;
      }
    }
    if (operations > 0) {
      await batch.commit();
    }
  }

  async deleteUserData(uid, leagueId) {
    const userRef = this._userDoc(uid);
    const progress = await userRef.collection('progress').get();
    const batch = this._db.batch();
    for (const doc of progress.docs) {
      batch.delete(doc.ref);
    }
    if (leagueId) {
      batch.delete(this._memberDoc(leagueId, uid));
    }
    batch.delete(userRef);
    await batch.commit();
  }
}

module.exports = {
  RankingRepository,
};
