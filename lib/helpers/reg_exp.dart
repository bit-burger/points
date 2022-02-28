/// All RegExp used in points

final supabaseUrl = RegExp(r"^https?:\/\/.+\..+");
final supabaseKey = RegExp(r"^(\.|\w){147}$");

final email = RegExp(r"^(?![-+.])(\w|[-+.])*\w@(?![-+.])(\w|[-+])*\w\.[a-z]+$");
final emailFilter = RegExp(r"[.a-zA-Z0-9+-_@]");

final pointsNameHyphenSpaceCheck = RegExp("(^-| )|(-| )\$");
final pointsSimpleName = RegExp(r'^([a-z-]|\s)+$');
