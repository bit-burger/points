import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class NeumorphicScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final bool extendBodyBehindAppBar;
  final Widget body;
  final Widget? floatingActionButton;

  const NeumorphicScaffold({
    this.appBar,
    this.extendBodyBehindAppBar = false,
    required this.body,
    this.floatingActionButton,
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
    );
  }
}
