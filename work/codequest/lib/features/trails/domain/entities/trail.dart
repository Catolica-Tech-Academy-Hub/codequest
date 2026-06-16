class Trail {
  const Trail({
    required this.id,
    required this.title,
    required this.description,
    required this.levelIds,
  });

  final String id;
  final String title;
  final String description;
  final List<String> levelIds;
}
