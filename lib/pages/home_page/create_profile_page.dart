import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:points/state_management/auth_cubit.dart';
import 'package:points/state_management/profile_cubit.dart';
import 'package:points/widgets/neumorphic_box.dart';
import 'package:points/widgets/neumorphic_chip_button.dart';
import 'package:points/widgets/neumorphic_loading_text_button.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:points/widgets/neumorphic_text_form_field.dart';
import 'package:points/widgets/shaker.dart';

class CreateProfilePage extends StatefulWidget {
  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final _form = GlobalKey<FormState>();
  final _shakerKey = GlobalKey<ShakerState>();

  bool _formFieldIsEmpty = true;
  late String _name;

  _buildNameForm() {
    return NeumorphicTextFormField(
      hintText: "Name",
      onSaved: (v) => _name = v!,
      validator: (v) {
        if (v == null || v == "") {
          return "Please give a name";
        } else if (v.length > 8) {
          return "Name can only be 8 characters long";
        }
        return null;
      },
      onFieldSubmitted: (_) => createProfile(),
      onChanged: (v) {
        if (v.isEmpty != _formFieldIsEmpty) {
          setState(() {
            _formFieldIsEmpty = v.isEmpty;
          });
        }
      },
    );
  }

  _buildButton() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return NeumorphicLoadingTextButton(
          loading: state is ProfileLoadingState,
          onPressed: _formFieldIsEmpty ? null : createProfile,
          child: Text("Create user"),
        );
      },
    );
  }

  _buildFooter() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: 2.5,
      children: [
        Text("Switch account?"),
        NeumorphicChipButton(
          onPressed: context.read<AuthCubit>().logOut,
          child: Text(
            "Log out",
          ),
        ),
        // NeumorphicButton(
        //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        //   onPressed: isLoading ? null : switchAuthMethod,
        //   style: NeumorphicStyle(
        //     boxShape: NeumorphicBoxShape.stadium(),
        //   ),
        //   child: Text(
        //     authMethod == AuthMethod.logIn ? "Sign up" : "Log in",
        //     style: TextStyle(
        //       fontWeight: FontWeight.w500,
        //       color: isLoading ? Theme.of(context).disabledColor : null,
        //     ),
        //   ),
        // )
      ],
    );
  }

  _buildForm() {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              text: "Creating a user with the account of the email: ",
              children: [
                TextSpan(
                  text: (context.read<AuthCubit>().state as LoggedInState)
                      .credentials
                      .email,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 24,
          ),
          _buildNameForm(),
          SizedBox(
            height: 24,
          ),
          _buildButton(),
          SizedBox(
            height: 16,
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicScaffold(
      appBar: NeumorphicAppBar(
        title: Text("Create your user"),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Shaker(
          key: _shakerKey,
          child: NeumorphicBox(
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  void createProfile() {
    if (_form.currentState!.validate()) {
      _form.currentState!.save();
      context.read<ProfileCubit>().createProfile(_name);
    } else {
      _shakerKey.currentState!.shake();
    }
  }
}
