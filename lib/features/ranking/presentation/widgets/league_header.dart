import 'package:flutter/material.dart';
import 'package:codequest/features/ranking/domain/league_info.dart';

/// Cabeçalho gamificado com dados da liga ativa.
///
/// Camada: presentation/widgets — apenas renderização.
class LeagueHeader extends StatelessWidget {
  const LeagueHeader({
    super.key,
    required this.leagueInfo,
  });

  final LeagueInfo leagueInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _tierGradient(leagueInfo.tier),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _tierGradient(leagueInfo.tier).first.withAlpha((0.4 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone / emoji da liga
          Text(
            _tierEmoji(leagueInfo.tier),
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(width: 16),
          // Dados da liga
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Liga ${leagueInfo.tier.label}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline_rounded,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Top ${leagueInfo.promotionThreshold} sobem',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Termina em ${leagueInfo.daysRemaining} dia${leagueInfo.daysRemaining != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Participantes
          Column(
            children: [
              Text(
                '${leagueInfo.totalParticipants}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const Text(
                'alunos',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _tierGradient(LeagueTier tier) {
    return switch (tier) {
      LeagueTier.bronze => [
        const Color(0xFFCD7F32),
        const Color(0xFF8B4513),
      ],
      LeagueTier.silver => [
        const Color(0xFF9E9E9E),
        const Color(0xFF424242),
      ],
      LeagueTier.gold => [
        const Color(0xFFFFD700),
        const Color(0xFFFF8C00),
      ],
      LeagueTier.diamond => [
        const Color(0xFF00BCD4),
        const Color(0xFF673AB7),
      ],
    };
  }

  String _tierEmoji(LeagueTier tier) {
    return switch (tier) {
      LeagueTier.bronze => '🥉',
      LeagueTier.silver => '🥈',
      LeagueTier.gold => '🏆',
      LeagueTier.diamond => '💎',
    };
  }
}
