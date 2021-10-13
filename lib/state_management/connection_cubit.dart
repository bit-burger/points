import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'connection_state.dart';

class ConnectionCubit extends Cubit<ConnectionState> {
  ConnectionCubit() : super(ConnectionWorkingState());

  void reportError() {
    assert(state is ConnectionWorkingState);

    emit(ConnectionFailedState());
  }

  void retry() {
    assert(state is ConnectionFailedState);

    emit(ConnectionWorkingState());
  }
}
