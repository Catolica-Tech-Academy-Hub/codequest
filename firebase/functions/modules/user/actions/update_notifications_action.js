class UpdateNotificationsAction {
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  async execute({ uid, enabled }) {
    if (typeof enabled !== 'boolean') {
      throw new Error('O campo "enabled" deve ser um booleano.');
    }
    await this.userRepository.updateNotifications(uid, enabled);
    return { uid, notificationsEnabled: enabled };
  }
}

module.exports = { UpdateNotificationsAction };
