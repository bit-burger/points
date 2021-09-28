import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'connection_state.dart';

class ConnectionCubit extends Cubit<ConnectionState> {
  ConnectionCubit() : super(ConnectionInitial());
}
