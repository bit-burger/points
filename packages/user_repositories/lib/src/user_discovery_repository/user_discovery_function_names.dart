const profileFromEmail = "profile_from_email";

String queryProfiles({
  bool searchWithName = false,
  bool sortByPopularity = false,
}) {
  var s = "query_profiles";

  if (searchWithName) {
    s += "_name";
  }

  if (sortByPopularity) {
    s += "_popularity";
  }
  return s;
}
