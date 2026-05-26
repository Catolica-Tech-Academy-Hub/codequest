/*import 'package:flutter/material.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking')),
      body: ListView(
        children: const <Widget>[
          _MockNotice(),
          ListTile(
            leading: CircleAvatar(child: Text('1')),
            title: Text('Dev User'),
            subtitle: Text('120 XP'),
            trailing: Icon(Icons.arrow_upward, color: Colors.green),
          ),
          ListTile(
            leading: CircleAvatar(child: Text('2')),
            title: Text('Alice'),
            subtitle: Text('100 XP'),
            trailing: Icon(Icons.remove, color: Colors.grey),
          ),
          ListTile(
            leading: CircleAvatar(child: Text('3')),
            title: Text('Bob'),
            subtitle: Text('90 XP'),
            trailing: Icon(Icons.arrow_downward, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class _MockNotice extends StatelessWidget {
  const _MockNotice();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            Icon(Icons.info_outline),
            SizedBox(width: 8),
            Expanded(
              child: Text('Mock: ranking fixo no front, ainda nao vem do Firestore.'),
            ),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ranking_providers.dart';
import 'widgets/league_header.dart';
import 'widgets/my_performance_card.dart';
import 'widgets/ranking_list_item.dart';
import 'widgets/ranking_podium.dart';

/// Tela principal de ranking gamificado.
///
/// Camada: presentation — apenas renderização e orquestração de widgets.
/// Toda a lógica de dados é delegada aos providers.
///
/// Usa [StreamBuilder] indiretamente via [AsyncValue] do Riverpod para
/// atualizar o ranking e o progresso do aluno em tempo real.
class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leagueIdAsync = ref.watch(currentUserLeagueIdProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: leagueIdAsync.when(
        loading: () => const _LoadingState(),
        error: (e, _) => _ErrorState(message: e.toString()),
        data: (leagueId) {
          if (leagueId == null || leagueId.isEmpty) {
            return const _EmptyState();
          }
          return _RankingBody(leagueId: leagueId);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            'Ranking',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Corpo principal com StreamBuilders em tempo real
// ---------------------------------------------------------------------------

class _RankingBody extends ConsumerWidget {
  const _RankingBody({required this.leagueId});

  final String leagueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(leagueRankingStreamProvider(leagueId));
    final leagueAsync = ref.watch(leagueInfoStreamProvider(leagueId));
    final myEntryAsync = ref.watch(currentUserRankingEntryProvider(leagueId));

    return Column(
      children: [
        // Cabeçalho da liga — stream em tempo real
        leagueAsync.when(
          loading: () => const _ShimmerBlock(height: 100),
          error: (_, __) => const SizedBox.shrink(),
          data: (info) => LeagueHeader(leagueInfo: info),
        ),

        // Lista de ranking — stream em tempo real
        Expanded(
          child: rankingAsync.when(
            loading: () => const _LoadingState(),
            error: (e, _) => _ErrorState(message: e.toString()),
            data: (entries) {
              if (entries.isEmpty) {
                return const _EmptyState();
              }

              final topThree = entries.take(3).toList();
              final rest = entries.skip(3).toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Pódio gamificado (top 3)
                  SliverToBoxAdapter(
                    child: RankingPodium(topThree: topThree),
                  ),

                  // Divisor + label
                  SliverToBoxAdapter(
                    child: _SectionDivider(
                      label: 'Classificação Geral',
                    ),
                  ),

                  // Lista das demais posições (4+)
                  SliverList.builder(
                    itemCount: rest.length,
                    itemBuilder: (context, index) {
                      return RankingListItem(
                        key: ValueKey(rest[index].userId),
                        entry: rest[index],
                        animationDelay:
                        Duration(milliseconds: index * 40),
                      );
                    },
                  ),

                  // Espaçamento final para não ficar atrás do card fixo
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),

        // Card de desempenho do aluno — fixo na parte inferior, stream em tempo real
        myEntryAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (entry) =>
          entry != null ? MyPerformanceCard(entry: entry) : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets de estado
// ---------------------------------------------------------------------------

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _ShimmerBlock(height: 100),
        const SizedBox(height: 16),
        const _ShimmerBlock(height: 160),
        const SizedBox(height: 16),
        ...List.generate(
          5,
              (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ShimmerBlock(height: 68),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😵', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Não foi possível carregar o ranking.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏜️', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            'Nenhum aluno na liga ainda.',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete desafios para entrar no ranking!',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloco de shimmer simples enquanto carrega.
class _ShimmerBlock extends StatefulWidget {
  const _ShimmerBlock({required this.height});
  final double height;

  @override
  State<_ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<_ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(base, base.withOpacity(0.3), _anim.value),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: theme.colorScheme.outlineVariant,
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: theme.colorScheme.outlineVariant,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
