/// Type of notification, needed for interpreting the [Notification.]
enum NotificationType {
  systemMessage,
  changedRelation,
  gavePoints,
  /// not used
  pointsMilestone,
  receivedMessage,
  profileUpdate,
}

/// For getting the [NotificationType] from a [String] in json
NotificationType notificationTypeFromString(String s) {
  switch (s) {
    case "system_message":
      return NotificationType.systemMessage;
    case "changed_relation":
      return NotificationType.changedRelation;
    case "points_milestone":
      return NotificationType.pointsMilestone;
    case "received_message":
      return NotificationType.receivedMessage;
    case "profile_update":
      return NotificationType.profileUpdate;
    case "gave_points":
      return NotificationType.gavePoints;
  }
  throw Exception("'$s' could not be mapped to a NotificationType");
}
