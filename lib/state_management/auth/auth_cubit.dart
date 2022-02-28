import 'dart:async';

import 'package:auth_repository/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meta_repository/meta_repository.dart';
import '../../pages/auth/auth_page.dart';

part 'auth_state.dart';

/// Cubit for the authentication state,
/// also handles errors via the [reportConnectionError] method,
/// which all Cubits call to report an error,
/// to then show the [LoggedInPausedOnConnectionError] state.
class AuthCubit extends Cubit<AuthState> {
  final IAuthRepository _authRepository;
  final IMetadataRepository _metadataRepository;
  late final StreamSubscription connectivitySub;
  bool _lastIsConnected = true;

  AuthCubit(
      {required IMetadataRepository metadataRepository,
      required IAuthRepository authRepository})
      : _authRepository = authRepository,
        _metadataRepository = metadataRepository,
        super(AuthInitialState()) {
    connectivitySub = Connectivity().onConnectivityChanged.listen(
      (result) async {
        final isConnected = (result != ConnectivityResult.none);

        if (isConnected != _lastIsConnected) {
          if (isConnected &&
              state is! AuthInitialState &&
              state is! LoadingAuth &&
              state is! LoggedOutState) {
            _signInFromPersistedData();
          } else {
            emit(LoggedInPausedOnConnectionError());
          }
          _lastIsConnected = isConnected;
        }
      },
    );
  }

  void reportConnectionError() async {
    try {
      await _authRepository.logOut(keepPersistedData: true);
    } on AuthError {
      // do nothing as already inside the error view
    }
    emit(LoggedInPausedOnConnectionError());
  }

  void retryFromConnectionError() async {
    assert(state is LoggedInPausedOnConnectionError);
    emit(LoggedInPausedOnConnectionError(retrying: true));

    final res = await Future.wait([
      _metadataRepository.hasConnection(),
      Future.delayed(Duration(seconds: 1)),
    ]);
    final connected = res[0];

    if (connected) {
      _signInFromPersistedData();
    } else {
      emit(LoggedInPausedOnConnectionError());
    }
  }

  /// sign in from the persisted data
  ///
  /// The data is persisted in the [IAuthRepository]
  void tryToAutoSignIn() {
    assert(state is AuthInitialState);

    _signInFromPersistedData();
  }

  void _signInFromPersistedData() async {
    if (_authRepository.persistedLogInDataExists()) {
      try {
        final userId = await _authRepository.tryAutoSignIn();
        emit(LoggedInState(userId));
        print("Signed in from persisted: $userId");
      } on AuthAutoSignInFailedError {
        emit(LoggedOutState());
      } on AuthError {
        // can only be a connection error
        emit(LoggedInPausedOnConnectionError());
      }
    } else {
      emit(LoggedOutState());
    }
  }

  void logIn({required String email, required String password}) async {
    assert(state is LoggedOutState);

    emit(LoadingAuth());
    try {
      final res = await Future.wait([
        _authRepository.logIn(email, password),
        Future.delayed(Duration(milliseconds: 350)),
      ]);
      final userId = res[0];

      print("Logged in: $userId");
      emit(LoggedInState(userId));
    } on AuthError catch (e) {
      emit(LoggedOutState(e.type));
    }
  }

  void signUp({required String email, required String password}) async {
    assert(state is LoggedOutState);

    emit(LoadingAuth());
    try {
      final userId = await _authRepository.signUp(email, password);
      emit(LoggedInState(userId));
    } on AuthError catch (e) {
      emit(LoggedOutState(e.type));
    }
  }

  void logOut() async {
    assert(
      state is! LoggedOutState ||
          state is! LoadingAuth ||
          state is! AuthInitialState,
    );

    try {
      await _authRepository.logOut();
      emit(LoggedOutState());
    } on AuthError catch (e) {
      emit(LoggedOutState(e.type));
    }
  }

  /// Not currently used
  void deleteAccount() async {
    assert(state is LoggedInState);

    try {
      await _authRepository.deleteAccount();
      emit(LoggedOutState());
    } on AuthError catch (e) {
      emit(LoggedOutState(e.type));
    }
  }

  /// For the [AuthPage], if there has been an error, clear it
  void clearErrors() {
    assert(state is LoggedOutState);

    emit(LoggedOutState());
  }

  @override
  Future<void> close() async {
    await connectivitySub.cancel();
    return super.close();
  }
}
