import 'package:flutter/foundation.dart' as flutter;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> configureSupabase() async {
  final env = dotenv.env;
  final String? supabaseUrl = env["SUPABASE_URL"],
      supabaseAnonKey = env["SUPABASE_ANON_KEY"];

  assert(supabaseUrl != null, "The supabase url is missing");
  assert(supabaseAnonKey != null, "The supabase anon key is missing");

  assert(
    RegExp(r"^https?:\/\/.+\..+").hasMatch(supabaseUrl!),
    "The supabase url ($supabaseUrl) is invalid",
  );

  assert(
    RegExp(r"^(\.|\w){147}$").hasMatch(supabaseAnonKey!),
    "The supabase anon key ($supabaseAnonKey) is invalid",
  );

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    debug: !flutter.kReleaseMode, // optional
  );
}
