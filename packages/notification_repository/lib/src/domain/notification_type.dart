enum NotificationType {
  systemMessage,
  changedRelation,
  pointsMilestone,
  receivedMessage,
  profileUpdate,
  gavePoints,
}

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
