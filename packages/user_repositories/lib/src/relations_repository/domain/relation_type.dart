enum RelationType {
  /// The user is a friend
  friend,

  /// The user has sent a friend request
  pending,

  /// Self has sent a friend request to the user
  requesting,

  /// The user has been blocked by self
  blocked,

  /// Self has been blocked by the user
  blockedBy,
}

/// Used if the [RelationType] needs to be inferred from a [String] in json
RelationType relationTypeFromString(String s) {
  switch (s) {
    case "friends":
      return RelationType.friend;
    case "blocked_by":
      return RelationType.blockedBy;
    case "blocked":
      return RelationType.blocked;
    case "request_pending":
      return RelationType.requesting;
    case "requesting":
      return RelationType.pending;
    default:
      throw Exception("'$s' could not be mapped to a RelationType");
  }
}
