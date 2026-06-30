function welcomeEmail(userName) {
  return {
    subject: 'Bem-vindo ao CodeQuest! 🚀',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #6C63FF;">Bem-vindo ao CodeQuest!</h1>
        <p>Olá, <strong>${userName}</strong>!</p>
        <p>Estamos muito felizes em ter você conosco. O CodeQuest é sua jornada de aprendizado em Flutter e Dart.</p>
        <p>Comece agora:</p>
        <ul>
          <li>Complete atividades para ganhar XP</li>
          <li>Mantenha seu streak diário</li>
          <li>Suba de liga e desbloqueie avatares</li>
        </ul>
        <p>Bons estudos!</p>
        <p style="color: #888; font-size: 12px;">Equipe CodeQuest</p>
      </div>
    `,
  };
}

function leaguePromotionEmail(userName, oldTier, newTier) {
  const tierLabels = {
    bronze: 'Bronze',
    silver: 'Prata',
    gold: 'Ouro',
    diamond: 'Diamante',
  };

  const oldLabel = tierLabels[oldTier] || oldTier;
  const newLabel = tierLabels[newTier] || newTier;

  return {
    subject: `Parabéns! Você subiu para a liga ${newLabel}! 🏆`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #6C63FF;">Promoção de Liga! 🏆</h1>
        <p>Olá, <strong>${userName}</strong>!</p>
        <p>Parabéns! Você foi promovido da liga <strong>${oldLabel}</strong> para a liga <strong>${newLabel}</strong>!</p>
        <p>Continue se dedicando para alcançar o topo do ranking.</p>
        <p>Bons estudos!</p>
        <p style="color: #888; font-size: 12px;">Equipe CodeQuest</p>
      </div>
    `,
  };
}

function passwordResetEmail(userName) {
  return {
    subject: 'Recuperação de senha - CodeQuest',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #6C63FF;">Recuperação de Senha</h1>
        <p>Olá, <strong>${userName}</strong>!</p>
        <p>Recebemos uma solicitação para redefinir sua senha no CodeQuest.</p>
        <p>Se você não solicitou essa alteração, ignore este e-mail.</p>
        <p style="color: #888; font-size: 12px;">Equipe CodeQuest</p>
      </div>
    `,
  };
}

module.exports = {
  welcomeEmail,
  leaguePromotionEmail,
  passwordResetEmail,
};
