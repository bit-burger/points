import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:points/widgets/neumorphic_box.dart';
import 'package:points/widgets/points_logo.dart';

import 'package:flutter/material.dart' as flutter;

import '../../configure_package_info.dart';

/// Shows things like version and name to the user, also shows licenses.
///
/// Version and name provided by the package_info package,
/// which was configured in lib/configure_package_info.dart,
/// which was called in main.dart
class InfoDialog extends StatelessWidget {
  void showLicensePage(BuildContext context) {
    flutter.showLicensePage(
      context: context,
      applicationName: packageInfo.appName,
      applicationVersion: "v" + packageInfo.version,
      applicationLegalese: "Licensed under GPLv3",
      applicationIcon: Padding(
        padding: EdgeInsets.all(16),
        child: PointsLogo(size: 56),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NeumorphicBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            PointsLogo(size: 56),
            SizedBox(height: 16),
            Text(
              packageInfo.appName,
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              "v" + packageInfo.version,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 12),
            Text(
              "points is an app "
              "meant to mock other social media, "
              "by giving people worthless points. "
              "Other than that however, "
              "you are still able to search for people, "
              "give friend requests (and accept them), "
              "as well as chat with them",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: "(Licensed under GPLv3, "),
                  TextSpan(
                    text: "other licenses",
                    recognizer: (TapGestureRecognizer()
                      ..onTap = () => showLicensePage(context)),
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ")"),
                ],
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(fontStyle: FontStyle.italic, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
