class SampleController {
  constructor({ createSampleAction, listSamplesAction }) {
    this.createSampleAction = createSampleAction;
    this.listSamplesAction = listSamplesAction;
  }

  create = async (request, response) => {
    try {
      const result = await this.createSampleAction.execute({
        title: request.body?.title,
      });
      response.status(201).json(result);
    } catch (error) {
      response.status(400).json({ message: error.message });
    }
  };

  list = async (_request, response) => {
    try {
      const result = await this.listSamplesAction.execute();
      response.status(200).json(result);
    } catch (error) {
      response.status(500).json({ message: error.message });
    }
  };
}

module.exports = {
  SampleController,
};
