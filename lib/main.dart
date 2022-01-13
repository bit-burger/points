import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:points/points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:points/supabase_configuration.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'configure_package_info.dart';

void main() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  await dotenv.load(fileName: ".env");
  await configureSupabase();
  await Hive.initFlutter();
  await configurePackageInfo();

  final sessionStore = await Hive.openBox<String>("sessions");

  final app = Points(
    sessionStore: sessionStore,
  );

  runApp(app);
}
