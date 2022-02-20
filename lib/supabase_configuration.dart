import 'package:flutter/foundation.dart' as flutter;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../helpers/reg_exp.dart' as regExp;

/// Configure supabase use the credentials provided by the .env file.
///
/// The .env file is read and interpreted using flutter_dotenv.
Future<void> configureSupabase() async {
  final env = dotenv.env;
  final String? supabaseUrl = env["SUPABASE_URL"],
      supabaseAnonKey = env["SUPABASE_ANON_KEY"];

  assert(supabaseUrl != null, "The supabase url is missing");
  assert(supabaseAnonKey != null, "The supabase anon key is missing");

  assert(
    regExp.supabaseUrl.hasMatch(supabaseUrl!),
    "The supabase url ($supabaseUrl) is invalid",
  );

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    debug: !flutter.kReleaseMode, // optional
  );
}
