import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase/supabase.dart';

Future<SupabaseClient> getConfiguredSupabaseClient() async {
  final configData = await File(".env").readAsString();
  dotenv.testLoad(fileInput: configData);

  final supabaseUrl = dotenv.env["SUPABASE_URL"]!;
  final supabaseAnonKey = dotenv.env["SUPABASE_ANON_KEY"]!;

  return SupabaseClient(
    supabaseUrl,
    supabaseAnonKey,
  );
}
