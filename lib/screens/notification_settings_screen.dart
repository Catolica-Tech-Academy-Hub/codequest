import 'package:flutter/material.dart';

void main() {
  runApp(const NotificationPauseApp());
}

class NotificationPauseApp extends StatelessWidget {
  const NotificationPauseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Preferências',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const NotificationPreferencesPage(),
      const TemporaryDeactivationPage(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() => currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Notificações',
          ),
          NavigationDestination(
            icon: Icon(Icons.pause_circle_outline_rounded),
            selectedIcon: Icon(Icons.pause_circle_filled_rounded),
            label: 'Pausar',
          ),
        ],
      ),
    );
  }
}

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  int selectedCategory = 0;
  bool pushEnabled = true;
  bool emailEnabled = true;
  bool smsEnabled = false;
  bool marketingEnabled = true;
  bool remindersEnabled = true;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      leadingIcon: Icons.arrow_back_ios_new_rounded,
      trailingIcon: Icons.help_outline_rounded,
      title: 'Preferências de notificações',
      subtitle:
          'Escolha como o app pode falar com você e ajuste a intensidade dos avisos.',
      children: [
        SegmentedControl(
          values: const ['Geral', 'Pedidos', 'Conta'],
          selectedIndex: selectedCategory,
          onChanged: (index) => setState(() => selectedCategory = index),
        ),
        const SizedBox(height: 16),
        AppPanel(
          title: 'Canais',
          note: '${activeChannelsCount()} ativos',
          children: [
            SettingsSwitchTile(
              title: 'Push no celular',
              subtitle: 'Avisos rápidos sobre movimentações importantes.',
              value: pushEnabled,
              onChanged: (value) => setState(() => pushEnabled = value),
            ),
            SettingsSwitchTile(
              title: 'E-mail',
              subtitle: 'Resumo, comprovantes e atualizações de segurança.',
              value: emailEnabled,
              onChanged: (value) => setState(() => emailEnabled = value),
            ),
            SettingsSwitchTile(
              title: 'SMS',
              subtitle: 'Somente alertas críticos e confirmação de identidade.',
              value: smsEnabled,
              onChanged: (value) => setState(() => smsEnabled = value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppPanel(
          title: 'Tipos de aviso',
          note: 'Editar',
          children: [
            SettingsSwitchTile(
              title: 'Novidades e promoções',
              subtitle: 'Campanhas, recomendações e benefícios disponíveis.',
              value: marketingEnabled,
              onChanged: (value) => setState(() => marketingEnabled = value),
            ),
            SettingsSwitchTile(
              title: 'Lembretes',
              subtitle: 'Prazos, retornos pendentes e ações recomendadas.',
              value: remindersEnabled,
              onChanged: (value) => setState(() => remindersEnabled = value),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const InfoBanner(
          icon: Icons.check_rounded,
          text:
              'Notificações essenciais de segurança continuarão ativas para proteger sua conta.',
          tone: BannerTone.success,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.save_outlined),
          label: const Text('Salvar preferências'),
        ),
      ],
    );
  }

  int activeChannelsCount() {
    return [pushEnabled, emailEnabled, smsEnabled, marketingEnabled]
        .where((enabled) => enabled)
        .length;
  }
}

class TemporaryDeactivationPage extends StatefulWidget {
  const TemporaryDeactivationPage({super.key});

  @override
  State<TemporaryDeactivationPage> createState() =>
      _TemporaryDeactivationPageState();
}

class _TemporaryDeactivationPageState extends State<TemporaryDeactivationPage> {
  int selectedDuration = 0;

  final options = const [
    PauseOption(
      title: '7 dias',
      description: 'Bom para uma pausa curta sem alterar sua rotina.',
    ),
    PauseOption(
      title: '15 dias',
      description: 'Indicado para férias, viagens ou períodos corridos.',
    ),
    PauseOption(
      title: '30 dias',
      description: 'Para quando você precisa se afastar por mais tempo.',
    ),
    PauseOption(
      title: 'Personalizar',
      description: 'Escolha uma data específica de reativação.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppPage(
      leadingIcon: Icons.arrow_back_ios_new_rounded,
      trailingIcon: Icons.close_rounded,
      title: 'Desativação temporária',
      subtitle:
          'Pause sua conta por um período definido. Você pode voltar antes do prazo quando quiser.',
      children: [
        const InfoBanner(
          icon: Icons.priority_high_rounded,
          text:
              'Durante a pausa, seu perfil fica oculto e novas solicitações ficam bloqueadas.',
          tone: BannerTone.warning,
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final useTwoColumns = constraints.maxWidth >= 330;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: useTwoColumns ? 2 : 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: useTwoColumns ? 1.28 : 3.2,
              ),
              itemBuilder: (context, index) {
                final option = options[index];
                return PauseOptionCard(
                  option: option,
                  selected: selectedDuration == index,
                  onTap: () => setState(() => selectedDuration = index),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        const DateSummaryTile(),
        const SizedBox(height: 16),
        const AppPanel(
          title: 'O que será pausado',
          children: [
            CheckInfoTile(
              title: 'Visibilidade do perfil',
              subtitle: 'Seu perfil não aparece em buscas ou recomendações.',
            ),
            CheckInfoTile(
              title: 'Novas interações',
              subtitle:
                  'Convites, mensagens iniciais e solicitações serão suspensos.',
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          minLines: 3,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Motivo da pausa, opcional',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.line),
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.pause_rounded),
          label: Text('Pausar conta por ${options[selectedDuration].title}'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () {},
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({
    required this.leadingIcon,
    required this.trailingIcon,
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });

  final IconData leadingIcon;
  final IconData trailingIcon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleIconButton(icon: leadingIcon, onPressed: () {}),
            CircleIconButton(icon: trailingIcon, onPressed: () {}),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.08,
                color: AppColors.ink,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
                height: 1.45,
              ),
        ),
        const SizedBox(height: 22),
        ...children,
      ],
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        fixedSize: const Size(42, 42),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.line),
      ),
    );
  }
}

class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    required this.values,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<String> values;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          for (var index = 0; index < values.length; index++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 6),
                child: TextButton(
                  onPressed: () => onChanged(index),
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(38),
                    backgroundColor:
                        selectedIndex == index ? Colors.white : Colors.transparent,
                    foregroundColor: selectedIndex == index
                        ? AppColors.ink
                        : AppColors.muted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: Text(values[index]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppPanel extends StatelessWidget {
  const AppPanel({
    required this.title,
    required this.children,
    this.note,
    super.key,
  });

  final String title;
  final String? note;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.panelHeader,
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (note != null)
                  Text(
                    note!,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          for (var index = 0; index < children.length; index++)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: index == children.length - 1
                      ? BorderSide.none
                      : const BorderSide(color: AppColors.line),
                ),
              ),
              child: children[index],
            ),
        ],
      ),
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

enum BannerTone { success, warning }

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    required this.icon,
    required this.text,
    required this.tone,
    super.key,
  });

  final IconData icon;
  final String text;
  final BannerTone tone;

  @override
  Widget build(BuildContext context) {
    final isWarning = tone == BannerTone.warning;
    final color = isWarning ? AppColors.warningText : AppColors.successText;
    final background =
        isWarning ? AppColors.warningBackground : AppColors.successBackground;
    final border = isWarning ? AppColors.warningBorder : AppColors.successBorder;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class PauseOption {
  const PauseOption({required this.title, required this.description});

  final String title;
  final String description;
}

class PauseOptionCard extends StatelessWidget {
  const PauseOptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final PauseOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.line,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(.12),
                    blurRadius: 0,
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? AppColors.primary : AppColors.muted,
                  size: 20,
                ),
              ],
            ),
            Text(
              option.description,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DateSummaryTile extends StatelessWidget {
  const DateSummaryTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reativação automática',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 3),
                Text(
                  '29 de junho de 2026, às 08:00',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}

class CheckInfoTile extends StatelessWidget {
  const CheckInfoTile({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_rounded, color: AppColors.successText),
        ],
      ),
    );
  }
}

class AppColors {
  static const background = Color(0xFFEEF2F6);
  static const ink = Color(0xFF19212A);
  static const muted = Color(0xFF6D7682);
  static const line = Color(0xFFDFE5EC);
  static const soft = Color(0xFFF3F6F9);
  static const panelHeader = Color(0xFFF8FAFC);
  static const primary = Color(0xFF246BFE);
  static const danger = Color(0xFFC63D3D);
  static const successText = Color(0xFF1E6245);
  static const successBackground = Color(0xFFF0F8F5);
  static const successBorder = Color(0xFFCCE8DC);
  static const warningText = Color(0xFF7A471C);
  static const warningBackground = Color(0xFFFFF8EF);
  static const warningBorder = Color(0xFFF0D3AF);
}
