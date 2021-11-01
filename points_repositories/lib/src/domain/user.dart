class User {
  final String id;
  final String name, status, bio;
  final int color, icon;
  final int points;

  User({
    required this.id,
    required this.name,
    required this.status,
    required this.bio,
    required this.color,
    required this.icon,
    required this.points,
  }) {
    assert(name.length <= 8);
    assert(status.length <= 16);
    assert(bio.length <= 256);

    assert(color == color.clamp(0, 9));
    assert(icon == icon.clamp(0, 255));
    assert(points >= 0);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      bio: json['bio'],
      color: json['color'],
      icon: json['icon'],
      points: json['points'],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is User &&
      other.id == id &&
      other.name == name &&
      other.status == status &&
      other.bio == bio &&
      other.color == color &&
      other.icon == icon &&
      other.points == points;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        status,
        bio,
        color,
        icon,
        points,
      );
}
