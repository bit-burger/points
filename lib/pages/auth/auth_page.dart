import 'dart:async';

import 'package:auth_repository/auth_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:points/helpers/uppercase_to_lowercase_text_input_formatter.dart';
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:points/widgets/hider.dart';
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/neumorphic_box.dart';
import 'package:points/widgets/neumorphic_chip_button.dart';
import 'package:points/widgets/neumorphic_loading_text_button.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:points/widgets/neumorphic_text_form_field.dart';
import 'package:points/widgets/shaker.dart';
import '../../helpers/reg_exp.dart' as regExp;

/// Lets the user log in and sign up
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
              ? "Email or password wrong"
              : "Email already in use")
          : null,
      hintText: "Email",
      key: _emailForm,
      autofocus: true,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter(
          regExp.emailFilter,
          allow: true,
        ),
        UppercaseToLowercaseTextInputFormatter(),
      ],
      validator: (s) {
        if ((s == null || !regExp.email.hasMatch(s))) {
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
      builder: (_, validated, __) {
        return NeumorphicLoadingTextButton(
          padding: EdgeInsets.zero,
          loading: isLoading,
          loader: SizedBox(
            height: 56,
            child: Loader(compact: true),
          ),
          child: SizedBox(
            height: 56,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 250),
              child: Text(
                authMethod == AuthMethod.logIn ? "Log in" : "Sign up",
                key: ValueKey(authMethod),
              ),
            ),
          ),
          onPressed: validated ? logInOrSignUp : null,
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
              NeumorphicChipButton(
                onPressed: isLoading ? null : switchAuthMethod,
                child: Text(
                  authMethod == AuthMethod.logIn ? "Sign up" : "Log in",
                ),
              ),
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
            buildWhen: (oldState, newState) => newState is! LoadingAuth,
            builder: (context, state) {
              AuthErrorType? errorType;
              if (state is LoggedOutState) {
                errorType = state.logInError;
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
              if (state is LoggedOutState) {
                errorType = state.logInError;
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLoginButton(state is LoadingAuth),
                  SizedBox(
                    height: 16,
                  ),
                  _buildFooter(
                    errorType == AuthErrorType.connection,
                    state is LoadingAuth,
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
      body: SafeArea(
        child: ListView(
          physics: PageScrollPhysics(),
          children: [
            SizedBox(
              height: NeumorphicAppBar.toolbarHeight,
              child: NeumorphicAppBar(
                leading: SizedBox(),
                centerTitle: true,
                title: AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  child: Text(
                    authMethod == AuthMethod.logIn ? "Log in" : "Sign up",
                    key: ValueKey(authMethod),
                  ),
                ),
              ),
            ),
            BlocListener<AuthCubit, AuthState>(
              listener: (_, state) {
                if (state is LoggedOutState && state.logInError != null) {
                  authErrorHandler(state.logInError!);
                }
                if (state is LoggedInState) {
                  loggedInHandler(state.credentials);
                }
              },
              child: Shaker(
                key: _shakerKey,
                child: BlocBuilder<AuthCubit, AuthState>(
                  buildWhen: (oldState, newState) {
                    return oldState is LoadingAuth || newState is LoadingAuth;
                  },
                  builder: (context, state) {
                    return IgnorePointer(
                      ignoring: state is LoadingAuth,
                      child: NeumorphicBox(
                        child: _buildForm(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
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

  /// Make TextFormFieldsConform
  /// Because this can happen after:
  /// An actual login, a sign up or a auto log in,
  /// the Form always needs to look the same:
  /// No password, email filled out
  void loggedInHandler(AccountCredentials credentials) {
    // _emailForm.currentState!.setValue(credentials.email);
    // _passwordForm.currentState!.setValue("");
    _passwordForm.currentState!.reset();
    checkIfFormValid();
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
    if (authCubit.state is LoadingAuth) {
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
      final email = _emailForm.currentState?.value;
      final password = _passwordForm.currentState?.value;
      final isValid =
          email != "" && email != null && password != "" && password != null;
      _formIsValidNotifier.value = isValid;
    });
  }

  @override
  void initState() {
    // TODO: User controllers for loggedInHandler
    // final authState = context.read<AuthCubit>().state;
    // if(authState is LoggedInState) {
    //   loggedInHandler(authState.credentials);
    // }
    super.initState();
  }
}
