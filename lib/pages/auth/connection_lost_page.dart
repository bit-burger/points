import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide ConnectionState;
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:points/widgets/neumorphic_box.dart';
import 'package:points/widgets/neumorphic_loading_text_button.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:points/widgets/shaker.dart';

/// If the [AuthCubit] emits that it has an error,
/// this page is displayed by the [AuthNavigator],
/// to give the user the option to log in or retry the connection
class ConnectionLostPage extends StatefulWidget {
  @override
  State<ConnectionLostPage> createState() => _ConnectionLostPageState();
}

class _ConnectionLostPageState extends State<ConnectionLostPage> {
  final GlobalKey<ShakerState> shakerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return NeumorphicScaffold(
      extendBodyBehindAppBar: true,
      appBar: NeumorphicAppBar(
        title: Text(
          "Connection lost",
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
                      "The connection was lost, "
                      "reconnect or log out",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 36,
                    ),
                    NeumorphicLoadingTextButton(
                      child: Text("Reconnect"),
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
