import 'package:auth_repository/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final IAuthRepository _repository;

  AuthCubit({required IAuthRepository repository})
      : _repository = repository,
        super(AuthInitialState());

  void tryToAutoSignIn() async {
    assert(state is AuthInitialState);

    try {
      final userId = await _repository.tryAutoSignIn();
      emit(LoggedInState(userId));
    } on AuthAutoSignFailedError {
      emit(LoggedOutState());
    } on AuthError catch (e) {
      emit(LoggedOutWithErrorState(e.type));
    }
  }

  void logIn({required String email, required String password}) async {
    assert(state is LoggedOutState);

    emit(LoadingState());
    try {
      final userId = await _repository.logIn(email, password);
      emit(LoggedInState(userId));
    } on AuthError catch (e) {
      emit(LoggedOutWithErrorState(e.type));
    }
  }

  void signUp({required String email, required String password}) async {
    assert(state is LoggedOutState);

    emit(LoadingState());
    try {
      final userId = await _repository.signUp(email, password);
      emit(LoggedInState(userId));
    } on AuthError catch (e) {
      emit(LoggedOutWithErrorState(e.type));
    }
  }

  void logOut() {
    assert(state is LoggedInState);

    _repository.logOut();
    emit(LoggedOutState());
  }

  void clearErrors() {
    assert(state is LoggedOutState);

    emit(LoggedOutState());
  }
}
