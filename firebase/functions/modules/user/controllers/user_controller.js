class UserController {
  constructor({ updateProfileAction, updateNotificationsAction, deleteAccountAction }) {
    this.updateProfileAction = updateProfileAction;
    this.updateNotificationsAction = updateNotificationsAction;
    this.deleteAccountAction = deleteAccountAction;
  }

  updateProfile = async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) throw new Error('Não autenticado.');

    return this.updateProfileAction.execute({
      uid,
      name: data.name,
      bio: data.bio,
    });
  };

  updateNotifications = async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) throw new Error('Não autenticado.');

    return this.updateNotificationsAction.execute({
      uid,
      enabled: data.enabled,
    });
  };

  deleteAccount = async (_data, context) => {
    const uid = context.auth?.uid;
    if (!uid) throw new Error('Não autenticado.');

    await this.deleteAccountAction.execute({ uid });
    return { success: true };
  };
}

module.exports = { UserController };
