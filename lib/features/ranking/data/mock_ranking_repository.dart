import '../domain/league_info.dart';
import '../domain/ranking_entry.dart';
import '../domain/ranking_repository_contract.dart';

// =============================================================================
// RF01 — Mock do repositório de ranking (dados locais)
//
// 📌 SUBSTITUIÇÃO FUTURA:
// Quando a integração com o Firestore estiver pronta, basta trocar o provider
// em `ranking_providers.dart` de [MockRankingRepository] para
// [RankingRepository] (implementação real em `ranking_repository.dart`).
//
// Nenhuma alteração será necessária na camada de presentation, pois ambos
// implementam o mesmo contrato [RankingRepositoryContract] (DIP — SOLID).
// =============================================================================

/// Implementação mock do [RankingRepositoryContract] com dados locais.
///
/// Camada: data — substituto temporário enquanto o backend não está integrado.
/// Respeita o contrato definido no domínio sem importar Firebase ou Flutter.
class MockRankingRepository implements RankingRepositoryContract {
  /// Lista mockada de usuários ordenados por XP decrescente.
  ///
  /// 📌 SUBSTITUIÇÃO FUTURA:
  /// Estes dados serão substituídos por uma query Firestore:
  ///   _firestore.collection('users')
  ///     .where('leagueId', isEqualTo: leagueId)
  ///     .orderBy('xpTotal', descending: true)
  ///     .limit(limit)
  ///     .snapshots()
  static const _mockUsers = [
    RankingEntry(
      userId: 'mock-user-001',
      displayName: 'Ana Beatriz',
      avatarUrl: null, // Usará inicial do nome como fallback
      xpTotal: 2850,
      position: 1,
      streakDays: 15,
      leagueId: 'liga-bronze-01',
      isCurrentUser: false,
      positionChange: 2,
    ),
    RankingEntry(
      userId: 'mock-user-002',
      displayName: 'Carlos Eduardo',
      avatarUrl: null,
      xpTotal: 2340,
      position: 2,
      streakDays: 12,
      leagueId: 'liga-bronze-01',
      isCurrentUser: true, // Simula o usuário logado
      positionChange: 0,
    ),
    RankingEntry(
      userId: 'mock-user-003',
      displayName: 'Fernanda Lima',
      avatarUrl: null,
      xpTotal: 1980,
      position: 3,
      streakDays: 8,
      leagueId: 'liga-bronze-01',
      isCurrentUser: false,
      positionChange: -1,
    ),
    RankingEntry(
      userId: 'mock-user-004',
      displayName: 'Diego Santos',
      avatarUrl: null,
      xpTotal: 1520,
      position: 4,
      streakDays: 5,
      leagueId: 'liga-bronze-01',
      isCurrentUser: false,
      positionChange: 1,
    ),
    RankingEntry(
      userId: 'mock-user-005',
      displayName: 'Juliana Rocha',
      avatarUrl: null,
      xpTotal: 1100,
      position: 5,
      streakDays: 3,
      leagueId: 'liga-bronze-01',
      isCurrentUser: false,
      positionChange: -2,
    ),
  ];

  /// Dados mockados da liga.
  ///
  /// 📌 SUBSTITUIÇÃO FUTURA:
  /// Será substituído por:
  ///   _firestore.collection('leagues').doc(leagueId).snapshots()
  static final _mockLeagueInfo = LeagueInfo(
    leagueId: 'liga-bronze-01',
    tier: LeagueTier.bronze,
    endsAt: DateTime.now().add(const Duration(days: 12)),
    promotionThreshold: 3,
    totalParticipants: 5,
  );

  @override
  Stream<List<RankingEntry>> watchLeagueRanking({
    required String leagueId,
    required String currentUserId,
    int limit = 50,
  }) {
    // 📌 SUBSTITUIÇÃO FUTURA:
    // Trocar por stream real do Firestore (ver RankingRepository).
    // O stream abaixo simula a emissão única de dados mockados.
    return Stream.value(_mockUsers);
  }

  @override
  Stream<LeagueInfo> watchLeagueInfo({required String leagueId}) {
    // 📌 SUBSTITUIÇÃO FUTURA:
    // Trocar por stream real do Firestore (ver RankingRepository).
    return Stream.value(_mockLeagueInfo);
  }

  @override
  Future<String?> fetchUserLeagueId({required String userId}) async {
    // 📌 SUBSTITUIÇÃO FUTURA:
    // Trocar pela leitura real do documento do usuário no Firestore:
    //   final doc = await _firestore.collection('users').doc(userId).get();
    //   return doc.data()?['leagueId'] as String?;
    return 'liga-bronze-01';
  }
}
