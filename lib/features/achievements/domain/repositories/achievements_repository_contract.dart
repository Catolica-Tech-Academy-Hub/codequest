import 'package:codequest/features/achievements/domain/entities/achievement.dart';
import 'package:codequest/features/achievements/domain/entities/achievement_status.dart';

abstract class AchievementsRepositoryContract {
  /// Pede ao servidor para avaliar as conquistas do usuário autenticado e
  /// retorna as que foram desbloqueadas nesta verificação.
  Future<List<Achievement>> check();

  /// Observa o catálogo completo de conquistas marcado com o estado de
  /// desbloqueio do usuário logado (atualiza ao desbloquear).
  Stream<List<AchievementStatus>> watchAll();
}
