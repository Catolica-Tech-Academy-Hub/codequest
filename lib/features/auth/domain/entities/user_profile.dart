/// Entidade de domínio que representa o perfil público de um usuário.
///
/// Não deve conter imports de Flutter, Firebase ou qualquer detalhe de
/// infraestrutura — apenas Dart puro (DIP / Clean Architecture).
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.leagueId,
    required this.createdAt,
    this.avatarUrl,
    this.settings = const {},
    this.bio,
    this.notificationsEnabled = true,
  });

  /// Identificador único do usuário (geralmente o UID do Auth provider).
  final String uid;

  /// E-mail cadastrado.
  final String email;

  /// Nome de exibição do usuário.
  final String name;

  /// Liga em que o usuário está inscrito.
  final String leagueId;

  /// Data de criação do perfil.
  final DateTime createdAt;

  /// URL do avatar do usuário (pode ser nulo caso não tenha sido definido).
  final String? avatarUrl;

  /// Mapa livre de configurações do usuário (ex.: tema, notificações, idioma).
  final Map<String, dynamic> settings;

  final String? bio;
  final bool notificationsEnabled;

  UserProfile copyWith({
    String? email,
    String? name,
    String? leagueId,
    DateTime? createdAt,
    String? avatarUrl,
    Map<String, dynamic>? settings,
    String? bio,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      uid: uid,
      email: email ?? this.email,
      name: name ?? this.name,
      leagueId: leagueId ?? this.leagueId,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      settings: settings ?? this.settings,
      bio: bio ?? this.bio,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
