import 'package:user_repositories/src/relations_repository/domain/relation_type.dart';

import '../../domain_shared/user.dart';

/// A user that is related to the current user,
/// for example a friend or somebody that the user has blocked
class RelatedUser extends User {
  /// The current relationship between the two
  final RelationType relationType;

  /// The chatId, can only be used,
  /// if the [relationType] is [RelationType.friend]
  final String chatId;

  RelatedUser({
    required String id,
    required this.relationType,
    required this.chatId,
    required String name,
    required String status,
    required String bio,
    required int color,
    required int icon,
    required int points,
    required int gives,
  }) : super(
          id: id,
          name: name,
          status: status,
          bio: bio,
          color: color,
          icon: icon,
          points: points,
          gives: gives,
        );

  RelatedUser copyWithNewRelationType(RelationType relationType) {
    return RelatedUser(
      id: id,
      relationType: relationType,
      chatId: chatId,
      name: name,
      status: status,
      bio: bio,
      color: color,
      icon: icon,
      points: points,
      gives: gives,
    );
  }

  factory RelatedUser.fromJson(
    Map<String, dynamic> json, {
    RelationType? relationType,
    String? chatId,
  }) {
    return RelatedUser(
      id: json["id"],
      relationType: relationType ?? relationTypeFromString(json["state"]),
      chatId: chatId ?? json["chat_id"],
      name: json["name"],
      status: json["status"],
      bio: json["bio"],
      color: json["color"],
      icon: json["icon"],
      points: json["points"],
      gives: json["gives"],
    );
  }
}
