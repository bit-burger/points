import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

/// Taken and modified from https://github.com/Idean/Flutter-Neumorphic/blob/master/lib/src/widget/app_bar.dart
class NeumorphicAppBar extends StatefulWidget implements PreferredSizeWidget {
  static const toolbarHeight = kToolbarHeight + 16 * 2;
  static const defaultSpacing = 4.0;

  /// The primary widget displayed in the app bar.
  ///
  /// Typically a [Text] widget that contains a description of the current
  /// contents of the app.
  final Widget title;

  /// A widget to display before the [title].
  ///
  /// Typically the [leading] widget is an [Icon] or an [IconButton].
  ///
  /// Becomes the leading component of the [NavigationToolBar] built
  /// by this widget. The [leading] widget's width and height are constrained to
  /// be no bigger than toolbar's height, which is [kToolbarHeight].
  ///
  /// If this is null and [automaticallyImplyLeading] is set to true, the
  /// [NeumorphicAppBar] will imply an appropriate widget. For example, if the [NeumorphicAppBar] is
  /// in a [Scaffold] that also has a [Drawer], the [Scaffold] will fill this
  /// widget with an [IconButton] that opens the drawer (using [Icons.menu]). If
  /// there's no [Drawer] and the parent [Navigator] can go back, the [NeumorphicAppBar]
  /// will use a [NeumorphicBackButton] that calls [Navigator.maybePop].
  final Widget? leading;

  /// Whether the title should be centered.
  ///
  /// Defaults to being adapted to the current [TargetPlatform].
  final bool? centerTitle;

  /// Should there be space between leading, title and trailing
  final bool middleSpacing;

  /// Widgets to display in a row after the [title] widget.
  ///
  /// Typically these widgets are [IconButton]s representing common operations.
  /// For less common operations, consider using a [PopupMenuButton] as the
  /// last action.
  ///
  /// The [actions] become the trailing component of the [NavigationToolBar] built
  /// by this widget. The height of each action is constrained to be no bigger
  /// than the toolbar's height, which is [kToolbarHeight].
  final Widget? trailing;

  @override
  final Size preferredSize;

  NeumorphicAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.centerTitle,
    this.trailing,
    this.middleSpacing = true,
  })  : preferredSize = Size.fromHeight(toolbarHeight),
        super(key: key);

  @override
  NeumorphicAppBarState createState() => NeumorphicAppBarState();

  bool _getEffectiveCenterTitle(ThemeData theme, NeumorphicThemeData nTheme) {
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
    }
  }
}

class NeumorphicAppBarTheme extends InheritedWidget {
  final Widget child;

  NeumorphicAppBarTheme({required this.child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }

  static NeumorphicAppBarTheme? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }
}

class NeumorphicAppBarState extends State<NeumorphicAppBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nTheme = NeumorphicTheme.of(context);
    final AppBarTheme appBarTheme = AppBarTheme.of(context);
    return Container(
      child: SafeArea(
        bottom: false,
        child: NeumorphicAppBarTheme(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: NavigationToolbar(
              leading: widget.leading,
              middle: DefaultTextStyle(
                style: (appBarTheme.textTheme?.headline5 ??
                        Theme.of(context).textTheme.headline5!)
                    .merge(nTheme?.current?.appBarTheme.textStyle),
                child: widget.title,
              ),
              trailing: Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(
                      width: kToolbarHeight, height: kToolbarHeight),
                  child: widget.trailing,
                ),
              ),
              centerMiddle: widget.centerTitle ??
                  widget._getEffectiveCenterTitle(theme, nTheme!.current!),
              middleSpacing:
                  widget.middleSpacing ? NavigationToolbar.kMiddleSpacing : 0,
            ),
          ),
        ),
      ),
    );
  }
}
