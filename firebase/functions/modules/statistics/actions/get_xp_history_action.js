const DEFAULT_WEEKS = 12;
const MAX_WEEKS = 52;

class GetXpHistoryAction {
  constructor(statisticsRepository) {
    this.statisticsRepository = statisticsRepository;
  }

  async execute({ uid, weeks }) {
    if (!uid) {
      throw new Error('uid é obrigatório.');
    }

    const parsed = Number(weeks);
    const safeWeeks = Number.isFinite(parsed)
      ? Math.min(Math.max(Math.trunc(parsed), 1), MAX_WEEKS)
      : DEFAULT_WEEKS;

    const entries = await this.statisticsRepository.listXpHistory({
      uid,
      weeks: safeWeeks,
    });

    return { entries };
  }
}

module.exports = {
  GetXpHistoryAction,
  DEFAULT_WEEKS,
  MAX_WEEKS,
};
