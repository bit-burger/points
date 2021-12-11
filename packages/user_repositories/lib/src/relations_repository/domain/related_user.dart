import '../../domain_shared/user.dart';

class RelatedUser extends User {
  final String chatId;

  RelatedUser({
    required String id,
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

  factory RelatedUser.fromJson(
    Map<String, dynamic> json, {
    String? chatId,
  }) {
    return RelatedUser(
      id: json["id"],
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
