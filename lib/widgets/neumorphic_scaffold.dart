import 'package:flutter_neumorphic/flutter_neumorphic.dart';

/// A scaffold, with the background of the current neumorphic theme
///
/// Should not be used, as a normal [Scaffold] should be used instead.
@deprecated
class NeumorphicScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final bool extendBodyBehindAppBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;


  const NeumorphicScaffold({
    this.appBar,
    this.extendBodyBehindAppBar = false,
    required this.body,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset,
  }) : super();

  @override
  Widget build(BuildContext context) {
    final theme = NeumorphicTheme.of(context)!.current!;
    return Scaffold(
      appBar: appBar,
      body: body,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: theme.baseColor,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
