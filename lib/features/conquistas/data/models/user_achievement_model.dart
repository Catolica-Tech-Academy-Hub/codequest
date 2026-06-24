import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_achievement.dart';

/// Modelo de dados para serialização/desserialização do [UserAchievement] no Firestore.
///
/// A coleção `achievements` contém os documentos de definição de cada conquista.
/// A sub-coleção `users/{userId}/achievements` contém o progresso do usuário.
class UserAchievementModel extends UserAchievement {
  const UserAchievementModel({
    required super.userId,
    required super.achievement,
    required super.isUnlocked,
    super.unlockedAt,
    required super.currentProgress,
    required super.targetProgress,
  });

  factory UserAchievementModel.fromFirestore({
    required DocumentSnapshot<Map<String, dynamic>> progressDoc,
    required Achievement achievement,
    required String userId,
  }) {
    final data = progressDoc.data()!;
    return UserAchievementModel(
      userId: userId,
      achievement: achievement,
      isUnlocked: data['isUnlocked'] as bool? ?? false,
      unlockedAt: data['unlockedAt'] != null
          ? (data['unlockedAt'] as Timestamp).toDate()
          : null,
      currentProgress: data['currentProgress'] as int? ?? 0,
      targetProgress: data['targetProgress'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'achievementId': achievement.id,
        'isUnlocked': isUnlocked,
        'unlockedAt':
            unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
        'currentProgress': currentProgress,
        'targetProgress': targetProgress,
      };

  /// Cria o mapa de atualização parcial para o Firestore (sem sobrescrever tudo).
  Map<String, dynamic> toProgressUpdate(int newProgress, bool nowUnlocked) => {
        'currentProgress': newProgress,
        if (nowUnlocked) ...{
          'isUnlocked': true,
          'unlockedAt': Timestamp.fromDate(DateTime.now()),
        },
      };
}
