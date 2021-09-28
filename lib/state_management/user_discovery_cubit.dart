import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'user_discovery_state.dart';

class UserDiscoveryCubit extends Cubit<UserDiscoveryState> {
  UserDiscoveryCubit() : super(UserDiscoveryInitial());
}
