import 'package:auth_repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:meta_repository/meta_repository.dart';
import 'package:points/theme/points_theme.dart' as pointsTheme;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/auth/auth_navigator.dart';
import 'state_management/auth/auth_cubit.dart';

class Points extends StatelessWidget {
  final Box<String> sessionStore;

  Points({required this.sessionStore}) : super();

  Widget _buildHome() {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => AuthRepository(
            client: Supabase.instance.client,
            sessionStore: sessionStore,
          ),
        ),
        RepositoryProvider(
          create: (_) => MetadataRepository(
            client: Supabase.instance.client,
          ),
        ),
      ],
      child: BlocProvider<AuthCubit>(
        create: (context) => AuthCubit(
          metadataRepository: context.read<MetadataRepository>(),
          authRepository: context.read<AuthRepository>(),
        )..tryToAutoSignIn(),
        child: AuthNavigator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InAppNotification(
      child: NeumorphicTheme(
        themeMode: ThemeMode.light,
        theme: pointsTheme.neumorphic,
        child: IconTheme(
          data: pointsTheme.neumorphic.iconTheme,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
            theme: pointsTheme.material,
            home: _buildHome(),
          ),
        ),
      ),
    );
  }
}
