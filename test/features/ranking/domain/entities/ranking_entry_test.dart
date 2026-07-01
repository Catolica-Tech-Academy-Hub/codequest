// Caminho corrigido: sem a pasta "entities"
import 'package:codequest/features/ranking/domain/ranking_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RankingEntry Gamification Tests', () {
    test('Deve validar a igualdade de dois status idênticos (Equatable)', () {
      const entry1 = RankingEntry(
        userId: 'aluno_123',
        displayName: 'Jogador 1',
        xpTotal: 2500,
        position: 3,
        streakDays: 10,
        leagueId: 'prata',
      );

      const entry2 = RankingEntry(
        userId: 'aluno_123',
        displayName: 'Jogador 1',
        xpTotal: 2500,
        position: 3,
        streakDays: 10,
        leagueId: 'prata',
      );

      expect(entry1, equals(entry2));
    });

    test('Deve reconhecer alteração no sistema quando o jogador ganha XP', () {
      const baseEntry = RankingEntry(
        userId: 'aluno_123',
        displayName: 'Jogador 1',
        xpTotal: 2500,
        position: 3,
        streakDays: 10,
        leagueId: 'prata',
      );

      const moreXpEntry = RankingEntry(
        userId: 'aluno_123',
        displayName: 'Jogador 1',
        xpTotal: 2600, // XP aumentou
        position: 3,
        streakDays: 10,
        leagueId: 'prata',
      );

      expect(baseEntry, isNot(equals(moreXpEntry)));
    });

    test('Deve reconhecer alteração no sistema quando o Streak aumenta', () {
      const baseEntry = RankingEntry(
        userId: 'aluno_123',
        displayName: 'Jogador 1',
        xpTotal: 2500,
        position: 3,
        streakDays: 10,
        leagueId: 'prata',
      );

      const moreStreakEntry = RankingEntry(
        userId: 'aluno_123',
        displayName: 'Jogador 1',
        xpTotal: 2500,
        position: 3,
        streakDays: 11, // Streak aumentou
        leagueId: 'prata',
      );

      expect(baseEntry, isNot(equals(moreStreakEntry)));
    });
  });
}
