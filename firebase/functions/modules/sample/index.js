const { SampleRepository } = require('./repositories/sample_repository');
const { CreateSampleAction } = require('./actions/create_sample_action');
const { ListSamplesAction } = require('./actions/list_samples_action');
const { SampleController } = require('./controllers/sample_controller');

function createSampleModule() {
  const repository = new SampleRepository();
  const createAction = new CreateSampleAction(repository);
  const listAction = new ListSamplesAction(repository);

  return new SampleController({
    createSampleAction: createAction,
    listSamplesAction: listAction,
  });
}

module.exports = {
  createSampleModule,
};
