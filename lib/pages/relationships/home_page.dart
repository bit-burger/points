import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:points/state_management/auth_cubit.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeumorphicScaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            context.read<AuthCubit>().logOut();
          },
          child: Text("Log out"),
        ),
      ),
    );
  }
}
