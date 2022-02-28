import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:points/state_management/give_friend_points/give_friend_points_cubit.dart';
import 'package:points/theme/points_colors.dart';
import 'package:points/widgets/neumorphic_box.dart';
import '../home/home_navigator.dart';

/// A dialog to give a friend a specified amount of points via a slider.
/// The range of the slider is changed in realtime,
/// depending on how many gives the user has.
///
/// Only uses the [GiveFriendPointsCubit].
///
/// Can be opened for the preferred friend from [HomeNavigator]
class GiveFriendPointsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final friendPointsCubit = context.read<GiveFriendPointsCubit>();
    return Center(
      child: NeumorphicBox(
        child: BlocConsumer<GiveFriendPointsCubit, GiveFriendPointsState>(
          listener: (context, state) {
            if (state is GiveFriendsPointsFinished) {
              Navigator.pop(context);
            }
          },
          buildWhen: (oldState, newState) =>
              newState is! GiveFriendsPointsFinished,
          builder: (context, rawState) {
            final state = rawState as GiveFriendPointsData;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Do you want to give ${state.friend.name} " +
                      (state.lastGive
                          ? "your last point?"
                          : "${state.howManyPoints} "
                              "point${state.howManyPoints == 1 ? "" : "s"}?"),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      // fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 16),
                Text(
                  "(You have ${state.howManyPointsLimit} gives)",
                  style: TextStyle(color: textLabelColor),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                if (!state.lastGive) ...[
                  SizedBox(height: 24),
                  Center(
                    child: FractionallySizedBox(
                      widthFactor:
                          ((min(state.howManyPointsLimit.toDouble(), 6))) / 6,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("0", style: TextStyle(color: textLabelColor)),
                          SizedBox(width: 4),
                          Expanded(
                            child: NeumorphicSlider(
                              value: state.howManyPoints.toDouble(),
                              min: 0,
                              max: state.howManyPointsLimit.toDouble(),
                              onChangeStart: (v) {},
                              onChanged: (val) {
                                if (val.round() != state.howManyPoints) {
                                  friendPointsCubit.setHowManyPoints(
                                    newAmount: max(1, val.round()),
                                  );
                                }
                              },
                              style: SliderStyle(
                                depth: 4,
                                accent: white,
                                variant: white,
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(state.howManyPointsLimit.toString(),
                              style: TextStyle(color: textLabelColor)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                SizedBox(height: 16),
                SizedBox(
                  height: 56,
                  child: NeumorphicButton(
                    child: Center(
                      child: Text(
                        "give points",
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    onPressed: () {
                      context.read<GiveFriendPointsCubit>().givePoints();
                    },
                    style: NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.stadium(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
