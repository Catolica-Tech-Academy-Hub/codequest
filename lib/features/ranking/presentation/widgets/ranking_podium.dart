import 'package:flutter/material.dart';

import '../../domain/ranking_entry.dart';

/// Exibe o pódio gamificado com os 3 primeiros colocados.
///
/// Camada: presentation/widgets — apenas renderização, sem lógica de negócio.
class RankingPodium extends StatelessWidget {
  const RankingPodium({
    super.key,
    required this.topThree,
  });

  final List<RankingEntry> topThree;

  @override
  Widget build(BuildContext context) {
    if (topThree.isEmpty) return const SizedBox.shrink();

    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2º lugar
          Expanded(
            child: _PodiumSlot(
              entry: second,
              podiumHeight: 80,
              crownColor: const Color(0xFFC0C0C0),
              crownLabel: '🥈',
              rank: 2,
            ),
          ),
          // 1º lugar (mais alto)
          Expanded(
            child: _PodiumSlot(
              entry: first,
              podiumHeight: 110,
              crownColor: const Color(0xFFFFD700),
              crownLabel: '👑',
              rank: 1,
              isFirst: true,
            ),
          ),
          // 3º lugar
          Expanded(
            child: _PodiumSlot(
              entry: third,
              podiumHeight: 60,
              crownColor: const Color(0xFFCD7F32),
              crownLabel: '🥉',
              rank: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.entry,
    required this.podiumHeight,
    required this.crownColor,
    required this.crownLabel,
    required this.rank,
    this.isFirst = false,
  });

  final RankingEntry? entry;
  final double podiumHeight;
  final Color crownColor;
  final String crownLabel;
  final int rank;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (entry == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Emoji de coroa/medalha
        Text(
          crownLabel,
          style: TextStyle(fontSize: isFirst ? 28 : 22),
        ),
        const SizedBox(height: 4),
        // Avatar com inicial
        _AvatarBadge(
          entry: entry!,
          size: isFirst ? 52 : 42,
          ringColor: crownColor,
          isCurrentUser: entry!.isCurrentUser,
        ),
        const SizedBox(height: 6),
        // Nome
        Text(
          entry!.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: entry!.isCurrentUser
                ? colorScheme.primary
                : colorScheme.onSurface,
          ),
        ),
        // XP
        Text(
          '${entry!.xpTotal} XP',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 6),
        // Degrau do pódio
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          height: podiumHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                crownColor.withOpacity(0.85),
                crownColor.withOpacity(0.4),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: crownColor.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Avatar circular com inicial do nome e anel colorido.
class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({
    required this.entry,
    required this.size,
    required this.ringColor,
    required this.isCurrentUser,
  });

  final RankingEntry entry;
  final double size;
  final Color ringColor;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final initial = entry.displayName.isNotEmpty
        ? entry.displayName[0].toUpperCase()
        : '?';

    return Container(
      width: size + 4,
      height: size + 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 3),
        boxShadow: isCurrentUser
            ? [
          BoxShadow(
            color: ringColor.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ]
            : null,
      ),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: ringColor.withOpacity(0.15),
        backgroundImage:
            entry.avatarUrl != null ? NetworkImage(entry.avatarUrl!) : null,
        child: entry.avatarUrl == null
            ? Text(
                initial,
                style: TextStyle(
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.bold,
                  color: ringColor,
                ),
              )
            : null,
      ),
    );
  }
}
