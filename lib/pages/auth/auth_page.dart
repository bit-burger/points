import 'dart:async';

import 'package:auth_repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:points/helpers/uppercase_to_lowercase_text_input_formatter.dart';
import 'package:points/state_management/auth_cubit.dart';
import 'package:points/widgets/hider.dart';
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:points/widgets/neumorphic_text_form_field.dart';
import 'package:points/widgets/shaker.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

enum AuthMethod {
  logIn,
  signUp,
}

class _AuthPageState extends State<AuthPage> {
  /// If it is showing the log in or sign up page
  AuthMethod authMethod = AuthMethod.logIn;

  /// Key of the [Shaker] widget (to shake on a invalid input)
  final _shakerKey = GlobalKey<ShakerState>();

  /// The stream is updated with each editing of the forms,
  /// if they are valid or not, to update the
  final _formIsValidNotifier = ValueNotifier<bool>(false);

  /// Keys of the different forms
  /// (the [NeumorphicTextFormFieldState] and the [Form] itself)
  final _form = GlobalKey<FormState>();

  final _emailForm = GlobalKey<NeumorphicTextFormFieldState>();
  final _passwordForm = GlobalKey<NeumorphicTextFormFieldState>();

  /// Values of the forms (instead of a [TextEditingController])
  late String _email;
  late String _password;

  /// Build methods

  _buildEmailForm(bool isEmailError) {
    return NeumorphicTextFormField(
      errorText: isEmailError
          ? (authMethod == AuthMethod.logIn
              ? "Email not found"
              : "Email already in use")
          : null,
      hintText: "Email",
      key: _emailForm,
      autofocus: true,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter(
          RegExp(r"[.a-zA-Z0-9+-_@]"),
          allow: true,
        ),
        UppercaseToLowercaseTextInputFormatter(),
      ],
      validator: (s) {
        final regexPattern =
            r"^(?![-+.])(\w|[-+.])*\w@(?![-+.])(\w|[-+])*\w\.[a-z]+$";
        final regex = new RegExp(regexPattern);
        if ((s == null || !regex.hasMatch(s))) {
          return 'Please enter a valid email address';
        }
        return null;
      },
      onFieldSubmitted: (_) {
        _emailForm.currentState!.validate();
      },
      onChanged: (s) {
        if (isEmailError) {
          context.read<AuthCubit>().clearErrors();
        }
        checkIfFormValid();
      },
      onSaved: (s) => _email = s!,
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.disabled,
    );
  }

  _buildPasswordForm(bool isPasswordError) {
    return NeumorphicTextFormField(
      errorText: isPasswordError ? "Password is false" : null,
      key: _passwordForm,
      hintText: "Password",
      onSaved: (s) => _password = s!,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      onChanged: (_) {
        if (isPasswordError) {
          context.read<AuthCubit>().clearErrors();
        }
        checkIfFormValid();
      },
      validator: (s) {
        if (s == null || s == "") {
          return 'Please enter a password';
        } else if (s.length < 6) {
          return 'Your password should be at least 6 characters long';
        }
        return null;
      },
      onFieldSubmitted: (_) => logInOrSignUp(),
      autovalidateMode: AutovalidateMode.disabled,
    );
  }

  // TODO: maybe not disable button, but only change font color, so when pressed the validation errors are shown (like on submit)
  _buildLoginButton(bool isLoading) {
    return ValueListenableBuilder<bool>(
      valueListenable: _formIsValidNotifier,
      builder: (_, isValidated, __) {
        final enabled = isValidated && !isLoading;
        return IgnorePointer(
          ignoring: !enabled,
          child: NeumorphicButton(
            child: Center(
              child: AnimatedCrossFade(
                crossFadeState: !isLoading
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  child: Text(
                    authMethod == AuthMethod.logIn ? "Log in" : "Sign up",
                    key: ValueKey(authMethod),
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                          color:
                              enabled ? null : Theme.of(context).disabledColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                secondChild: Loader(),
                firstCurve: Curves.easeOutExpo,
                secondCurve: Curves.easeOutExpo,
                duration: Duration(milliseconds: 250),
              ),
            ),
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.stadium(),
              depth:
                  enabled ? null : -NeumorphicTheme.of(context)!.current!.depth,
            ),
            duration: Duration(milliseconds: 250),
            onPressed: logInOrSignUp,
          ),
        );
      },
    );
  }

  _buildFooter(bool isConnectionError, bool isLoading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 16,
        ),
        Hider(
          hide: !isConnectionError,
          child: Text(
            "Connection failed, please check your internet before continuing, or try again later",
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).errorColor),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          child: Wrap(
            key: ValueKey(authMethod),
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 2.5,
            children: [
              Text("Don't have an account?"),
              NeumorphicButton(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                onPressed: isLoading ? null : switchAuthMethod,
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.stadium(),
                ),
                child: Text(
                  authMethod == AuthMethod.logIn ? "Sign up" : "Log in",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isLoading ? Theme.of(context).disabledColor : null,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  _buildForm() {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<AuthCubit, AuthState>(
            // Don't update the UI on LoadingState,
            // because errors will go away for the loading time,
            // but come back if nothing changed
            buildWhen: (oldState, newState) => newState is! LoadingState,
            builder: (context, state) {
              AuthErrorType? errorType;
              if (state is LoggedOutWithErrorState) {
                errorType = state.type;
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEmailForm(errorType == AuthErrorType.email),
                  SizedBox(
                    height: 24,
                  ),
                  _buildPasswordForm(errorType == AuthErrorType.password),
                ],
              );
            },
          ),
          SizedBox(
            height: 24,
          ),
          BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (oldState, newState) => newState is! LoggedInState,
            builder: (context, state) {
              AuthErrorType? errorType;
              if (state is LoggedOutWithErrorState) {
                errorType = state.type;
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLoginButton(state is LoadingState),
                  SizedBox(
                    height: 16,
                  ),
                  _buildFooter(
                    errorType == AuthErrorType.connection,
                    state is LoadingState,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return NeumorphicScaffold(
      appBar: NeumorphicAppBar(
        leading: SizedBox(),
        title: AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          child: Text(
            authMethod == AuthMethod.logIn ? "Log in" : "Sign up",
            key: ValueKey(authMethod),
          ),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (_, state) {
          if (state is LoggedOutWithErrorState) {
            authErrorHandler(state.type);
          }
        },
        child: Shaker(
          key: _shakerKey,
          child: Neumorphic(
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: _buildForm(),
            ),
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
            ),
          ),
        ),
      ),
    );
  }

  /// Switch from log in to sign up or vice versa
  void switchAuthMethod() {
    setState(() {
      authMethod =
          authMethod == AuthMethod.logIn ? AuthMethod.signUp : AuthMethod.logIn;
      context.read<AuthCubit>().clearErrors();
      _passwordForm.currentState!.reset();
      checkIfFormValid();
    });
  }

  /// On an error that is not a [AuthErrorType.connection] error,
  /// shake with the [_shakerKey]
  /// On an error that is a [AuthErrorType.password] error,
  /// reset the password with the [_passwordForm]
  void authErrorHandler(AuthErrorType errorType) {
    if (errorType != AuthErrorType.connection) {
      _shakerKey.currentState!.shake();
    }
    if (errorType == AuthErrorType.password) {
      _passwordForm.currentState!.reset();
      checkIfFormValid();
    }
  }

  /// Log in by validating the form
  /// On validation errors the Form will automatically be updated
  /// and the [Shaker] widget will be shaken
  void logInOrSignUp() {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state is LoadingState) {
      return;
    }
    if (_form.currentState!.validate()) {
      _form.currentState!.save();
      if (authMethod == AuthMethod.logIn) {
        authCubit.logIn(
          email: _email,
          password: _password,
        );
      } else {
        authCubit.signUp(
          email: _email,
          password: _password,
        );
      }
    } else {
      // TODO: Should vibrate a error with haptic feedback
      _shakerKey.currentState!.shake();
    }
  }

  /// Each time one of the [NeumorphicTextFormField]s are changed,
  /// this method is called to validate all of the forms
  /// and update the button (via the [_formIsValidNotifier])
  void checkIfFormValid() async {
    Future.microtask(() {
      final emailValid = (_emailForm.currentState?.isValid ?? false);
      final passwordValid = (_passwordForm.currentState?.isValid ?? false);
      final isValid = emailValid && passwordValid;
      _formIsValidNotifier.value = isValid;
    });
  }
}
