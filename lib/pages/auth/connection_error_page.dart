import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide ConnectionState;
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:points/widgets/neumorphic_box.dart';
import 'package:points/widgets/neumorphic_loading_text_button.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:points/widgets/shaker.dart';

class ConnectionErrorPage extends StatefulWidget {
  @override
  State<ConnectionErrorPage> createState() => _ConnectionErrorPageState();
}

class _ConnectionErrorPageState extends State<ConnectionErrorPage> {
  final GlobalKey<ShakerState> shakerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return NeumorphicScaffold(
      extendBodyBehindAppBar: true,
      appBar: NeumorphicAppBar(
        title: Text(
          "Connection error",
          style: TextStyle(color: Theme.of(context).errorColor),
        ),
        leading: SizedBox(),
      ),
      body: Center(
        child: Shaker(
          key: shakerKey,
          child: BlocConsumer<AuthCubit, AuthState>(
            listenWhen: (_, state) => state is LoggedInPausedOnConnectionError,
            buildWhen: (_, state) => state is LoggedInPausedOnConnectionError,
            listener: (context, state) {
              if (!(state as LoggedInPausedOnConnectionError).retrying) {
                shakerKey.currentState!.shake();
              }
            },
            builder: (context, state) {
              final loading =
                  (state as LoggedInPausedOnConnectionError).retrying;
              return NeumorphicBox(
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
                      loading: loading,
                      onPressed:
                          context.read<AuthCubit>().retryFromConnectionError,
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    NeumorphicLoadingTextButton(
                      child: Text("Log out"),
                      onPressed:
                          loading ? null : context.read<AuthCubit>().logOut,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
