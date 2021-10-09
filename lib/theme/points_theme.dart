import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'points_colors.dart' as pointsColors;

final neumorphic = NeumorphicThemeData();

final material = ThemeData(
  errorColor: pointsColors.errorColor,
  textTheme: GoogleFonts.courierPrimeTextTheme(),
);
