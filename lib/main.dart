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

  // configure the supabase with the .env file, hive for storing data
  // and the package info for the InfoDialog
  await dotenv.load(fileName: ".env");
  await configureSupabase();
  await Hive.initFlutter();
  await configurePackageInfo();

  // Box to store the credentials for auto log in,
  // injected into the AuthRepository
  final sessionStore = await Hive.openBox<String>("sessions");

  final app = Points(
    sessionStore: sessionStore,
  );

  runApp(app);
}
