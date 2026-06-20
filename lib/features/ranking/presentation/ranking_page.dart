import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codequest/features/ranking/providers/ranking_providers.dart';
import 'package:codequest/features/ranking/presentation/widgets/league_header.dart';
import 'package:codequest/features/ranking/presentation/widgets/my_performance_card.dart';
import 'package:codequest/features/ranking/presentation/widgets/ranking_podium.dart';
import 'package:codequest/features/ranking/presentation/widgets/ranking_list_item.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leagueIdAsync = ref.watch(currentUserLeagueIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
        centerTitle: true,
      ),
      body: leagueIdAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar liga: $e')),
        data: (leagueId) {
          if (leagueId == null) {
            return const Center(child: Text('Você ainda não está em uma liga.'));
          }
          return _RankingBody(leagueId: leagueId);
        },
      ),
    );
  }
}

class _RankingBody extends ConsumerWidget {
  const _RankingBody({required this.leagueId});

  final String leagueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(leagueRankingStreamProvider(leagueId));
    final leagueInfoAsync = ref.watch(leagueInfoStreamProvider(leagueId));
    final currentUserAsync = ref.watch(currentUserRankingEntryProvider(leagueId));

    return leagueInfoAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
      data: (leagueInfo) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: LeagueHeader(leagueInfo: leagueInfo),
            ),
            SliverToBoxAdapter(
              child: currentUserAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (entry) => entry != null
                    ? MyPerformanceCard(entry: entry)
                    : const SizedBox.shrink(),
              ),
            ),
            rankingAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Erro: $e')),
              ),
              data: (entries) {
                final top3 = entries.take(3).toList();
                final rest = entries.skip(3).toList();

                return SliverList(
                  delegate: SliverChildListDelegate([
                    if (top3.isNotEmpty) RankingPodium(topThree: top3),
                    const Divider(),
                    ...rest.map(
                          (entry) => RankingListItem(entry: entry),
                    ),
                  ]),
                );
              },
            ),
          ],
        );
      },
    );
  }
}