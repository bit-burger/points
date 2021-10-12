import 'user.dart';

class RootUser extends User {
  final int gives;

  RootUser(
    String id,
    String name,
    String status,
    String bio,
    int color,
    int icon,
    int points,
    this.gives,
  ) : super(id, name, status, bio, color, icon, points) {
    assert(gives >= 0);
  }

  factory RootUser.fromJson(Map<String, dynamic> json) {
    return RootUser(
      json['id'],
      json['name'],
      json['status'],
      json['bio'],
      json['color'],
      json['icon'],
      json['points'],
      json['gives'],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RootUser &&
      other.id == id &&
      other.name == name &&
      other.status == status &&
      other.bio == bio &&
      other.color == color &&
      other.icon == icon &&
      other.points == points &&
      other.gives == gives;

  int get hashCode => Object.hash(super.hashCode, gives);
}
