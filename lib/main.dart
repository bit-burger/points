import 'package:flutter/material.dart';
import 'package:points/points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:points/supabase_configuration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await configureSupabase();

  runApp(Points());
}
