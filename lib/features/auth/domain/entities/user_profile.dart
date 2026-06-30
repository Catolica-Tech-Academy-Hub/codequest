/// Entidade de domínio que representa o perfil público de um usuário.
///
/// Não deve conter imports de Flutter, Firebase ou qualquer detalhe de
/// infraestrutura — apenas Dart puro (DIP / Clean Architecture).
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.settings = const {},
    required this.leagueId,
    required this.createdAt,
  });

  /// Identificador único do usuário (geralmente o UID do Auth provider).
  final String id;

  /// Nome de exibição do usuário.
  final String name;

  /// E-mail cadastrado.
  final String email;

  /// URL do avatar do usuário (pode ser nulo caso não tenha sido definido).
  final String? avatarUrl;

  /// Mapa livre de configurações do usuário (ex.: tema, notificações, idioma).
  final Map<String, dynamic> settings;

  /// Liga em que o usuário está inscrito.
  final String leagueId;

  /// Data de criação do perfil.
  final DateTime createdAt;

  /// Cria uma cópia da entidade com campos opcionalmente sobrescritos.
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    Map<String, dynamic>? settings,
    String? leagueId,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      settings: settings ?? this.settings,
      leagueId: leagueId ?? this.leagueId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserProfile(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl)';
}
