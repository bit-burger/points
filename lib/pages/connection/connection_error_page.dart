import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide ConnectionState;
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:points/state_management/connection/connection_cubit.dart';
import 'package:points/widgets/neumorphic_box.dart';
import 'package:points/widgets/neumorphic_loading_text_button.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';

class ConnectionErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeumorphicScaffold(
      extendBodyBehindAppBar: true,
      appBar: NeumorphicAppBar(
        title: Text(
          "Connection error",
          style: TextStyle(color: Theme.of(context).errorColor),
        ),
      ),
      body: Center(
        child: NeumorphicBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 12,
              ),
              Text(
                "A connection error occurred, "
                "check your internet or try again later",
                style: TextStyle(color: Theme.of(context).errorColor),
              ),
              SizedBox(
                height: 36,
              ),
              NeumorphicLoadingTextButton(
                child: Text("Try again"),
                onPressed: context.read<ConnectionCubit>().retry,
              ),
              SizedBox(
                height: 24,
              ),
              NeumorphicLoadingTextButton(
                child: Text("Log out"),
                onPressed: context.read<AuthCubit>().logOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
