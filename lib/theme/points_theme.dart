import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'points_colors.dart' as pointsColors;

final neumorphic = NeumorphicThemeData();

final material = ThemeData(
  errorColor: pointsColors.errorColor,
  textTheme: GoogleFonts.courierPrimeTextTheme().apply(
    bodyColor: pointsColors.textColor,
    displayColor: pointsColors.textColor,
    decorationColor: pointsColors.textColor,
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: pointsColors.cursorColor,
    selectionHandleColor: pointsColors.cursorColor,
    selectionColor: pointsColors.textSelectionColor,
  ),
);
