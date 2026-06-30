class UpdateProfileAction {
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  async execute({ uid, name, bio }) {
    if (!name || name.trim().length < 2 || name.trim().length > 50) {
      throw new Error('Nome deve ter entre 2 e 50 caracteres.');
    }

    const trimmedBio = bio?.trim() ?? null;
    if (trimmedBio && trimmedBio.length > 160) {
      throw new Error('O recado deve ter no máximo 160 caracteres.');
    }

    await this.userRepository.update(uid, {
      name: name.trim(),
      bio: trimmedBio || null,
    });

    return { uid, name: name.trim(), bio: trimmedBio || null };
  }
}

module.exports = { UpdateProfileAction };
