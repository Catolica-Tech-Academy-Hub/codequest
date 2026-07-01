class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.leagueId,
    required this.createdAt,
    this.bio,
    this.notificationsEnabled = true,
  });

  final String uid;
  final String email;
  final String name;
  final String leagueId;
  final DateTime createdAt;
  final String? bio;
  final bool notificationsEnabled;

  UserProfile copyWith({
    String? name,
    String? bio,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      name: name ?? this.name,
      leagueId: leagueId,
      createdAt: createdAt,
      bio: bio ?? this.bio,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
