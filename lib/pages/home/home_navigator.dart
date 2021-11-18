import 'package:flutter/material.dart';
import 'package:points/pages/settings/icon_picker_page.dart';
import 'package:points/pages/settings/profile_page.dart';
import 'package:points/pages/user_discovery/user_discovery_page.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';

import 'home_page.dart';

class HomeNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: "home",
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "home":
            return MaterialPageRoute(builder: (_) => HomePage());
          case "user-discovery":
            return MaterialPageRoute(builder: (_) => UserDiscoveryPage());
          case "settings":
            return MaterialPageRoute(builder: (_) => ProfilePage());
          case "icons":
            return MaterialPageRoute(
              builder: (_) => IconPickerPage(),
              settings: settings,
            );
        }
      },
      onUnknownRoute: (_) {
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return NeumorphicScaffold(
              body: Center(
                child: RichText(
                  text: TextSpan(
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            color: Theme.of(context).errorColor,
                          ),
                      children: [
                        TextSpan(
                          text: "404: ",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: "Page not found",
                        ),
                      ]),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
