const { UserRepository } = require('./repositories/user_repository');
const { UpdateProfileAction } = require('./actions/update_profile_action');
const { UpdateNotificationsAction } = require('./actions/update_notifications_action');
const { DeleteAccountAction } = require('./actions/delete_account_action');
const { UserController } = require('./controllers/user_controller');

function createUserModule() {
  const repository = new UserRepository();
  const updateProfileAction = new UpdateProfileAction(repository);
  const updateNotificationsAction = new UpdateNotificationsAction(repository);
  const deleteAccountAction = new DeleteAccountAction(repository);

  return new UserController({
    updateProfileAction,
    updateNotificationsAction,
    deleteAccountAction,
  });
}

module.exports = { createUserModule };
