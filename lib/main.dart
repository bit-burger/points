import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:points/points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:points/supabase_configuration.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await configureSupabase();
  await Hive.initFlutter();

  final sessionStore = await Hive.openBox<String>("sessions");

  final app = Points(
    sessionStore: sessionStore,
  );

  runApp(app);
}
