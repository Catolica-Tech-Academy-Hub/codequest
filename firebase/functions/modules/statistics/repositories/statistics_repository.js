class StatisticsRepository {
  constructor({ db }) {
    this._db = db;
    this._users = db.collection('users');
  }

  /**
   * Lê o desempenho individual gravado em `users/{uid}`.
   * `position`/`positionChange` são mantidos pelo trigger recalculateLeagueRankings.
   */
  async getUserProfile(uid) {
    const snapshot = await this._users.doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    const data = snapshot.data() || {};
    return {
      userId: snapshot.id,
      displayName: typeof data.displayName === 'string' ? data.displayName : 'Aluno',
      xpTotal: typeof data.xpTotal === 'number' ? data.xpTotal : 0,
      streakDays: typeof data.streakDays === 'number' ? data.streakDays : 0,
      leagueId: typeof data.leagueId === 'string' ? data.leagueId : '',
      position: typeof data.position === 'number' ? data.position : null,
      positionChange: typeof data.positionChange === 'number' ? data.positionChange : 0,
    };
  }

  /**
   * Conta quantos usuários da mesma liga têm XP maior — base para a posição
   * quando o campo `position` ainda não foi recalculado. Usa aggregation
   * `count()` (apoiada no índice composto users(leagueId, xpTotal)), garantindo
   * resposta bem abaixo de 3s.
   */
  async countAhead({ leagueId, xpTotal }) {
    if (!leagueId) {
      return 0;
    }
    const snapshot = await this._users
      .where('leagueId', '==', leagueId)
      .where('xpTotal', '>', xpTotal)
      .count()
      .get();
    return snapshot.data().count;
  }

  /**
   * Lista os snapshots semanais de XP (evolução temporal), do mais recente para
   * o mais antigo. `.limit(weeks)` mantém a leitura barata.
   */
  async listXpHistory({ uid, weeks }) {
    const snapshot = await this._users
      .doc(uid)
      .collection('xpHistory')
      .orderBy('weekStart', 'desc')
      .limit(weeks)
      .get();

    return snapshot.docs.map((doc) => {
      const data = doc.data() || {};
      const weekStart = data.weekStart;
      return {
        weekStart:
          weekStart && typeof weekStart.toDate === 'function'
            ? weekStart.toDate().toISOString()
            : weekStart,
        xpTotal: typeof data.xpTotal === 'number' ? data.xpTotal : 0,
        xpGained: typeof data.xpGained === 'number' ? data.xpGained : 0,
        position: typeof data.position === 'number' ? data.position : null,
        streakDays: typeof data.streakDays === 'number' ? data.streakDays : 0,
      };
    });
  }
}

module.exports = {
  StatisticsRepository,
};
