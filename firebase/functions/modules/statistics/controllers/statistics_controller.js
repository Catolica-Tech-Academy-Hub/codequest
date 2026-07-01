const { HttpsError } = require('firebase-functions/v2/https');

class StatisticsController {
  constructor({ getPlayerStatsAction, getXpHistoryAction }) {
    this.getPlayerStatsAction = getPlayerStatsAction;
    this.getXpHistoryAction = getXpHistoryAction;
  }

  // Deriva o uid do contexto de auth do callable; permite consultar outro
  // usuário só explicitamente via data.userId (ranking/estatística é público).
  _resolveUid(request) {
    const uid = request.auth?.uid || request.data?.userId;
    if (!uid) {
      throw new HttpsError('unauthenticated', 'Necessário estar autenticado.');
    }
    return uid;
  }

  getPlayerStats = async (request) => {
    const uid = this._resolveUid(request);
    try {
      return await this.getPlayerStatsAction.execute({ uid });
    } catch (error) {
      throw new HttpsError('not-found', error.message);
    }
  };

  getXpHistory = async (request) => {
    const uid = this._resolveUid(request);
    try {
      return await this.getXpHistoryAction.execute({
        uid,
        weeks: request.data?.weeks,
      });
    } catch (error) {
      throw new HttpsError('invalid-argument', error.message);
    }
  };
}

module.exports = {
  StatisticsController,
};
