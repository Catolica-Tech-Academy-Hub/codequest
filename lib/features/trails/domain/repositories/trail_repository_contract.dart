import 'package:codequest/features/trails/domain/entities/trail.dart';
import 'package:codequest/features/trails/domain/entities/user_trail_progress.dart';

abstract class TrailRepositoryContract {
  Future<List<Trail>> listAll();
  Future<Trail> getById(String id);

  /// Recupera o progresso do usuário para uma trilha específica.
  Future<UserTrailProgress?> getUserProgress({
    required String userId,
    required String trailId,
  });

  /// Salva ou atualiza o progresso do usuário em uma trilha.
  Future<void> updateUserProgress(UserTrailProgress progress);
}
