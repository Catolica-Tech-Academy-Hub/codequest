class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.leagueId,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String name;
  final String leagueId;
  final DateTime createdAt;
}
