import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:notification_repository/notification_repository.dart';

/// Returns a icon from [Ionicons] for a [NotificationType]
IconData? iconDataFromNotificationType(NotificationType type) {
  switch (type) {
    case NotificationType.gavePoints:
      return Ionicons.person_add_outline;
    case NotificationType.pointsMilestone:
      return Ionicons.diamond_outline;
    case NotificationType.changedRelation:
      return Ionicons.people_outline;
    case NotificationType.profileUpdate:
      // person_circle_outline
      return Ionicons.id_card_outline;
    case NotificationType.receivedMessage:
      return Ionicons.chatbox_ellipses_outline;
    case NotificationType.systemMessage:
      return null;
  }
}
