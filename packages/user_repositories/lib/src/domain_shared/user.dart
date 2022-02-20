import 'dart:convert';

/// Represents a user profile in points
class User {
  final String id;
  final String name;
  final String status;
  final String bio;
  final int color;
  final int icon;
  final int points;
  final int gives;

  User({
    required this.id,
    required this.name,
    required this.status,
    required this.bio,
    required this.color,
    required this.icon,
    required this.points,
    required this.gives,
  }) {
    assert(name.length <= 8);
    assert(status.length <= 16);
    assert(bio.length <= 256);

    assert(color == color.clamp(0, 9));
    assert(icon == icon.clamp(0, 255));

    assert(points >= 0);
    assert(gives >= 0);
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
      gives: json['gives'],
    );
  }

  factory User.defaultWith({
    required String id,
  }) {
    return User(
      id: id,
      name: "alpha",
      status: "im new to points",
      bio: "Hi im alpha",
      color: 9,
      icon: 0,
      points: 100,
      gives: 10,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? status,
    String? bio,
    int? color,
    int? icon,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      bio: bio ?? this.bio,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      points: this.points,
      gives: this.gives,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "status": status,
      "bio": bio,
      "color": color,
      "icon": icon,
      "points": points,
      "gives": gives,
    };
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
      other.points == points &&
      other.gives == gives;

  @override
  int get hashCode => Object.hash(super.hashCode, gives);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
