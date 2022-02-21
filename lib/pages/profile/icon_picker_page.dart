import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide NeumorphicAppBar;
import 'package:ionicons/ionicons.dart';
import 'package:points/widgets/neumorphic_action.dart';
import 'package:points/widgets/neumorphic_app_bar_fix.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import '../../theme/points_icons.dart';
import 'profile_page.dart';

/// Pick a Icon for the [ProfilePage]
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

    return NeumorphicScaffold(
      extendBodyBehindAppBar: true,
      appBar: NeumorphicAppBar(
        title: SizedBox(),
        leading: NeumorphicAction.backButton(),
        trailing: NeumorphicAction(
          tooltip: "Zoom out",
          child: Center(
            child: Icon(
                Ionicons.remove_outline,
              size: 32,
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
        ),
        secondTrailing: NeumorphicAction(
          tooltip: "Zoom in",
          child: Center(
            child: Icon(
              Ionicons.add_outline,
              size: 32,
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
        ),
      ),
      body: BlocBuilder<InputFieldBloc<int, dynamic>, InputFieldBlocState>(
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
                  context
                      .read<InputFieldBloc<int, dynamic>>()
                      .updateValue(index);
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
