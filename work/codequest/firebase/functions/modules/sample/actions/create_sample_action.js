class CreateSampleAction {
  constructor(sampleRepository) {
    this.sampleRepository = sampleRepository;
  }

  async execute({ title }) {
    if (!title || !title.trim()) {
      throw new Error('Título é obrigatório.');
    }

    return this.sampleRepository.create({ title: title.trim() });
  }
}

module.exports = {
  CreateSampleAction,
};
