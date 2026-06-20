class ListSamplesAction {
  constructor(sampleRepository) {
    this.sampleRepository = sampleRepository;
  }

  async execute() {
    return this.sampleRepository.list();
  }
}

module.exports = {
  ListSamplesAction,
};
