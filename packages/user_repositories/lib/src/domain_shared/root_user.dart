import 'dart:convert';

import 'user.dart';

class RootUser extends User {
  final int gives;

  RootUser({
    required String id,
    required String name,
    required String status,
    required String bio,
    required int color,
    required int icon,
    required int points,
    required this.gives,
  }) : super(
          id: id,
          name: name,
          status: status,
          bio: bio,
          color: color,
          icon: icon,
          points: points,
        ) {
    assert(gives >= 0);
  }

  factory RootUser.fromJson(Map<String, dynamic> json) {
    return RootUser(
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

  factory RootUser.defaultWith({
    required String id,
  }) {
    return RootUser(
      id: id,
      name: "alpha",
      status: "im new to points",
      bio: "Hi im alpha",
      color: 9,
      icon: 0,
      points: 0,
      gives: 0,
    );
  }

  RootUser copyWith({
    String? id,
    String? name,
    String? status,
    String? bio,
    int? color,
    int? icon,
  }) {
    return RootUser(
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
      other is RootUser &&
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
