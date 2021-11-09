import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:supabase/supabase.dart';

const _urlKey = "SUPABASE_URL";
const _anonKey = "SUPABASE_ANON_KEY";
const _envPath = "../../.env";

Future<SupabaseClient> getConfiguredSupabaseClient() async {
  dotenv.load(_envPath);

  assert(
    dotenv.isEveryDefined([_urlKey, _anonKey]),
    "Not all key-value pairs needed for configuration "
    "of supabase for testing are given",
  );

  final supabaseUrl = dotenv.env[_urlKey]!;
  final supabaseAnonKey = dotenv.env[_anonKey]!;

  return SupabaseClient(
    supabaseUrl,
    supabaseAnonKey,
  );
}
