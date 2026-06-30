import 'package:codequest/features/auth/domain/entities/user_profile.dart';
import 'package:codequest/features/auth/providers/auth_providers.dart';
import 'package:codequest/features/profile/providers/profile_providers.dart';
import 'package:codequest/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Tela de perfil do usuário.
///
/// Widget fino — apenas consome estado via [profileNotifierProvider]
/// e delega ações de volta ao notifier. Nenhuma regra de negócio aqui.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(error: error),
        data: (profile) {
          if (profile == null) {
            return const _ErrorView(error: 'Perfil não encontrado.');
          }
          return _ProfileBody(profile: profile);
        },
      ),
    );
  }
}

// =============================================================================
// Header com avatar, nome, e-mail e badge
// =============================================================================

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // ------------------------------------------------------------------
        // Header com gradiente
        // ------------------------------------------------------------------
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.75),
                  colorScheme.primaryContainer,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                child: Column(
                  children: [
                    // Avatar
                    _AnimatedAvatar(
                      avatarUrl: profile.avatarUrl,
                      name: profile.name,
                    ),

                    const SizedBox(height: 16),

                    // Nome
                    Text(
                      profile.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // E-mail
                    Text(
                      profile.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Liga badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events_rounded,
                            size: 16,
                            color: Colors.amberAccent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            profile.leagueId.toUpperCase(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Estatísticas de Desempenho
                    _PerformanceStatsRow(profile: profile),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ------------------------------------------------------------------
        // Atalho para o ranking (RF01)
        // ------------------------------------------------------------------
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          sliver: SliverToBoxAdapter(
            child: _RankingShortcutCard(
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
        ),

        // ------------------------------------------------------------------
        // Seção de configurações
        // ------------------------------------------------------------------
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Configurações',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _SettingsCard(
              profile: profile,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
        ),

        // ------------------------------------------------------------------
        // Seção conta
        // ------------------------------------------------------------------
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Conta',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _AccountCard(isDark: isDark, colorScheme: colorScheme),
          ),
        ),

        // Espaço inferior para não colar na bottom nav
        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }
}

// =============================================================================
// Avatar animado
// =============================================================================

class _AnimatedAvatar extends StatelessWidget {
  const _AnimatedAvatar({required this.avatarUrl, required this.name});

  final String? avatarUrl;
  final String name;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 48,
        backgroundColor: Colors.white24,
        backgroundImage:
            avatarUrl != null ? NetworkImage(avatarUrl!) : null,
        child: avatarUrl == null
            ? Text(
                _initials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}

// =============================================================================
// Card de configurações (switches)
// =============================================================================

class _SettingsCard extends ConsumerWidget {
  const _SettingsCard({
    required this.profile,
    required this.isDark,
    required this.colorScheme,
  });

  final UserProfile profile;
  final bool isDark;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = profile.settings;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.notifications_active_rounded,
            iconColor: Colors.orange,
            title: 'Notificações',
            subtitle: 'Receber alertas de novos desafios',
            trailing: Switch.adaptive(
              value: settings['notifications_enabled'] == true,
              activeTrackColor: AppColors.primary,
              onChanged: (value) => _update(ref, 'notifications_enabled', value),
            ),
          ),
          const _TileDivider(),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            iconColor: Colors.deepPurple,
            title: 'Modo escuro',
            subtitle: 'Alternar aparência do app',
            trailing: Switch.adaptive(
              value: settings['dark_mode'] == true,
              activeTrackColor: AppColors.primary,
              onChanged: (value) => _update(ref, 'dark_mode', value),
            ),
          ),
          const _TileDivider(),
          _SettingsTile(
            icon: Icons.volume_up_rounded,
            iconColor: Colors.teal,
            title: 'Sons',
            subtitle: 'Efeitos sonoros durante os desafios',
            trailing: Switch.adaptive(
              value: settings['sounds_enabled'] != false,
              activeTrackColor: AppColors.primary,
              onChanged: (value) => _update(ref, 'sounds_enabled', value),
            ),
          ),
          const _TileDivider(),
          _SettingsTile(
            icon: Icons.translate_rounded,
            iconColor: Colors.indigo,
            title: 'Idioma',
            subtitle: settings['language']?.toString() ?? 'Português (BR)',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              // Delegado à UI de seleção (futuro)
            },
          ),
        ],
      ),
    );
  }

  void _update(WidgetRef ref, String key, dynamic value) {
    final updated = Map<String, dynamic>.from(profile.settings);
    updated[key] = value;
    ref.read(profileNotifierProvider.notifier).updateSettings(updated);
  }
}

// =============================================================================
// Card de conta (logout, etc.)
// =============================================================================

class _AccountCard extends ConsumerWidget {
  const _AccountCard({required this.isDark, required this.colorScheme});

  final bool isDark;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.shield_rounded,
            iconColor: Colors.blueGrey,
            title: 'Privacidade',
            subtitle: 'Gerencie seus dados',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          const _TileDivider(),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: Colors.cyan,
            title: 'Sobre o app',
            subtitle: 'Versão e licenças',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'CodeQuest',
                applicationVersion: '1.0.0',
              );
            },
          ),
          const _TileDivider(),
          _SettingsTile(
            icon: Icons.logout_rounded,
            iconColor: AppColors.danger,
            title: 'Sair da conta',
            subtitle: 'Encerrar sessão atual',
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.danger,
            ),
            onTap: () async {
              await ref.read(authControllerProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Componentes auxiliares de layout
// =============================================================================

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Ícone com fundo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),

            const SizedBox(width: 14),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            trailing,
          ],
        ),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 70,
      endIndent: 16,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
    );
  }
}

// =============================================================================
// Card de atalho para o ranking (RF01)
// =============================================================================

class _RankingShortcutCard extends StatelessWidget {
  const _RankingShortcutCard({
    required this.isDark,
    required this.colorScheme,
  });

  final bool isDark;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      color: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
      child: InkWell(
        onTap: () => context.go('/home/ranking'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Ícone com fundo gradiente
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade600,
                      Colors.orange.shade700,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ver Ranking',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Confira sua posição na classificação',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Tela de erro
// =============================================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.danger.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Não foi possível carregar o perfil',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Componentes de Estatística de Desempenho
// =============================================================================

/// TODO(Front-end): Extension temporária (Mock).
/// Os campos `xp`, `position` e `streak` devem vir diretamente da entidade
/// [UserProfile] ou [UserPerformance] quando a camada de dados for integrada.
/// Remova esta extension quando o backend/Repository estiver pronto.
extension UserProfileStatsExtension on UserProfile {
  int get xp => 1250;
  int get position => 42;
  int get streak => 7;
}

class _PerformanceStatsRow extends StatelessWidget {
  const _PerformanceStatsRow({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          label: 'XP',
          value: profile.xp.toString(),
          icon: Icons.star_rounded,
          color: Colors.orangeAccent,
        ),
        _StatItem(
          label: 'Posição',
          value: '#${profile.position}',
          icon: Icons.leaderboard_rounded,
          color: Colors.blueAccent,
        ),
        _StatItem(
          label: 'Ofensiva',
          value: '${profile.streak} dias',
          icon: Icons.local_fire_department_rounded,
          color: Colors.deepOrangeAccent,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
