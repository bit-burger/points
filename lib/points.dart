import 'package:auth_repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:points/theme/points_theme.dart' as pointsTheme;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/auth/auth_navigator.dart';
import 'state_management/auth_cubit.dart';

class Points extends StatelessWidget {
  final Box<String> sessionStore;

  Points({required this.sessionStore}) : super();

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository(
      authClient: Supabase.instance.client.auth,
      sessionStore: sessionStore,
    );
    return NeumorphicApp(
      title: "points",
      debugShowCheckedModeBanner: false,
      theme: pointsTheme.neumorphic,
      materialTheme: pointsTheme.material,
      home: BlocProvider<AuthCubit>(
        create: (_) => AuthCubit(repository: authRepository)..tryToAutoSignIn(),
        child: AuthNavigator(),
      ),
    );
  }
}
