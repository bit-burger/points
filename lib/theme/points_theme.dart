import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'points_colors.dart' as pointsColors;

final neumorphic = NeumorphicThemeData(
    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
    appBarTheme: NeumorphicAppBarThemeData(
      buttonStyle: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.circle(),
      ),
      icons: NeumorphicAppBarIcons(
        menuIcon: Icon(Ionicons.menu),
        closeIcon: Icon(Ionicons.close),
        forwardIcon: Icon(Ionicons.arrow_forward),
        backIcon: Icon(Ionicons.arrow_back),
      ),
    ));

final material = ThemeData(
  brightness: Brightness.light,
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
