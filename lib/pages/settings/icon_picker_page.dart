import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide NeumorphicAppBar;
import 'package:points/widgets/neumorphic_app_bar_fix.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import '../../theme/points_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IconPickerPage extends StatefulWidget {
  @override
  State<IconPickerPage> createState() => _IconPickerPageState();
}

class _IconPickerPageState extends State<IconPickerPage> {
  int howManyOnEachRow = 7;

  @override
  Widget build(BuildContext context) {
    final iconSize =
        (MediaQuery.of(context).size.width / howManyOnEachRow) * (2 / 3);
    // TODO: better solution than RouteSettings
    final inputFieldBloc = ModalRoute.of(context)!.settings.arguments
        as InputFieldBloc<int, dynamic>;

    return NeumorphicScaffold(
      extendBodyBehindAppBar: true,
      appBar: NeumorphicAppBar(
          title: SizedBox(),
          leading: NeumorphicBackButton(
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.circle(),
            ),
          ),
          trailing: NeumorphicButton(
            tooltip: "Zoom out",
            child: Center(
              child: Text(
                "-",
                style: TextStyle(fontSize: 36),
              ),
            ),
            onPressed: () {
              setState(
                () {
                  if (howManyOnEachRow < 10) {
                    howManyOnEachRow++;
                  }
                },
              );
            },
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.circle(),
            ),
          ),
          secondTrailing: NeumorphicButton(
            tooltip: "Zoom in",
            child: Center(
              child: Text(
                "+",
                style: TextStyle(fontSize: 36),
              ),
            ),
            onPressed: () {
              setState(
                () {
                  if (howManyOnEachRow > 3) {
                    howManyOnEachRow--;
                  }
                },
              );
            },
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.circle(),
            ),
          )),
      body: BlocBuilder<InputFieldBloc<int, dynamic>, InputFieldBlocState>(
        bloc: inputFieldBloc,
        builder: (context, state) {
          return GridView.builder(
            itemCount: pointsIcons.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: howManyOnEachRow,
            ),
            itemBuilder: (context, index) {
              return TextButton(
                key: ValueKey(index),
                onPressed: () {
                  inputFieldBloc.updateValue(index);
                },
                child: Icon(
                  pointsIcons[index],
                  size: iconSize,
                ),
                style: ButtonStyle(
                  animationDuration: Duration(milliseconds: 500),
                  backgroundColor: MaterialStateProperty.all(
                      state.value == index ? Colors.grey[350]! : null),
                  shape: MaterialStateProperty.all(CircleBorder()),
                  overlayColor: MaterialStateProperty.all(Colors.grey[350]),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
