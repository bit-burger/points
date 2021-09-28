import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:points/navigators/auth_navigator.dart';
import 'package:points/state_management/auth_cubit.dart';

class Points extends StatelessWidget {
  const Points() : super();

  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      title: "points",
      home: BlocProvider<AuthCubit>(
        create: (_) => AuthCubit(),
        child: AuthNavigator(),
      ),
    );
  }
}
