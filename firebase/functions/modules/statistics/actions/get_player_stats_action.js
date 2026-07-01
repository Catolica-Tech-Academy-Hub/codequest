class GetPlayerStatsAction {
  constructor(statisticsRepository) {
    this.statisticsRepository = statisticsRepository;
  }

  async execute({ uid }) {
    if (!uid) {
      throw new Error('uid é obrigatório.');
    }

    const profile = await this.statisticsRepository.getUserProfile(uid);
    if (!profile) {
      throw new Error('Perfil não encontrado.');
    }

    // Posição recalculada pelo trigger é a fonte primária; se ainda não existe,
    // calcula sob demanda contando quem tem mais XP na liga.
    let position = profile.position;
    if (typeof position !== 'number' || position < 1) {
      const ahead = await this.statisticsRepository.countAhead({
        leagueId: profile.leagueId,
        xpTotal: profile.xpTotal,
      });
      position = ahead + 1;
    }

    return {
      userId: profile.userId,
      xpTotal: profile.xpTotal,
      position,
      streakDays: profile.streakDays,
      leagueId: profile.leagueId,
      positionChange: profile.positionChange,
    };
  }
}

module.exports = {
  GetPlayerStatsAction,
};
