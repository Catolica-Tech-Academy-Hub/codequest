const admin = require('firebase-admin');

class DeleteAccountAction {
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  async execute({ uid }) {
    // Deleta dados do Firestore primeiro (ainda autenticado via token verificado)
    await this.userRepository.delete(uid);

    // Deleta o usuário do Firebase Auth via Admin SDK
    await admin.auth().deleteUser(uid);
  }
}

module.exports = { DeleteAccountAction };
