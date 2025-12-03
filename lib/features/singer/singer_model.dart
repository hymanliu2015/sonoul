class Singer {
  final String id;
  final String name;
  final String avatarUrl;

  Singer({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  factory Singer.fromJson(Map<String, dynamic> json) {
    return Singer(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }
}
