const admin = require('firebase-admin');

/**
 * Processa o ciclo da liga (promoções, rebaixamentos, premiação e reset de XP).
 */
async function processLeagueCycle() {
  const db = admin.firestore();
  
  const LEAGUE_TIERS = {
    bronze: { next: 'silver', prev: null },
    silver: { next: 'gold', prev: 'bronze' },
    gold: { next: 'diamond', prev: 'silver' },
    diamond: { next: null, prev: 'gold' },
  };

  let batch = db.batch();
  let operationCount = 0;

  const commitBatchIfNeeded = async () => {
    if (operationCount >= 400) {
      await batch.commit();
      batch = db.batch(); // Reinicia o batch
      operationCount = 0;
    }
  };

  try {
    const leaguesSnapshot = await db.collection('leagues').get();
    
    // Armazena as ligas mapeadas pelo tier para facilitar a transferência de usuários
    const leaguesByTier = {};
    leaguesSnapshot.docs.forEach(doc => {
      const data = doc.data();
      leaguesByTier[data.tier] = doc.id;
    });

    for (const leagueDoc of leaguesSnapshot.docs) {
      const tier = leagueDoc.data().tier;
      if (!LEAGUE_TIERS[tier]) continue;

      // Busca membros da liga atual ordenados por XP (maior para menor)
      const membersRef = db.collection(`leagues/${leagueDoc.id}/members`);
      const membersSnapshot = await membersRef.orderBy('xpTotal', 'desc').get();
      
      if (membersSnapshot.empty) continue;
      
      const members = membersSnapshot.docs;
      const totalMembers = members.length;
      
      for (let i = 0; i < totalMembers; i++) {
        const memberDoc = members[i];
        const memberData = memberDoc.data();
        const userId = memberDoc.id;
        const userRef = db.collection('users').doc(userId);
        
        let newTier = tier;
        let action = 'maintain';

        // 1. Premiação de Avatares (Top 3)
        if (i < 3) {
          const avatarId = `avatar_${tier}_${i + 1}`;
          batch.set(userRef, {
            unlockedAvatars: admin.firestore.FieldValue.arrayUnion(avatarId)
          }, { merge: true });
          operationCount++;
          await commitBatchIfNeeded();
        }

        // 2. Promoção (Top 15)
        if (i < 15 && LEAGUE_TIERS[tier].next) {
          newTier = LEAGUE_TIERS[tier].next;
          action = 'promote';
        } 
        // 3. Rebaixamento (Últimos 15), protegendo ligas muito pequenas
        else if (i >= totalMembers - 15 && LEAGUE_TIERS[tier].prev && totalMembers > 30) {
          newTier = LEAGUE_TIERS[tier].prev;
          action = 'demote';
        }

        // Se mudou de liga (promovido ou rebaixado)
        if (action !== 'maintain') {
          const destLeagueId = leaguesByTier[newTier];
          
          if (destLeagueId) {
            // Remove da liga atual
            batch.delete(memberDoc.ref);
            operationCount++;

            // Adiciona na nova liga (com XP zerado para a nova semana)
            const destMemberRef = db.collection(`leagues/${destLeagueId}/members`).doc(userId);
            batch.set(destMemberRef, {
              ...memberData,
              xpTotal: 0, // Reset de XP da liga
              leagueId: destLeagueId
            });
            operationCount++;

            // Atualiza os metadados no perfil do usuário
            batch.set(userRef, { 
              tier: newTier,
              leagueId: destLeagueId
            }, { merge: true });
            operationCount++;
          }
        } 
        // Se se manteve na mesma liga
        else {
          batch.update(memberDoc.ref, { xpTotal: 0 }); // Apenas reseta o XP
          operationCount++;
        }

        await commitBatchIfNeeded();
      }
    }

    if (operationCount > 0) {
      await batch.commit();
    }

    console.log('Ciclo de ligas (Promoção/Rebaixamento/Reset) processado com sucesso.');
  } catch (error) {
    console.error('Erro ao processar o ciclo de ligas:', error);
  }
}

module.exports = {
  processLeagueCycle
};
