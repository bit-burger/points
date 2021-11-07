import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:user_repositories/profile_repository.dart';

import 'connection_cubit.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final IProfileRepository _profileRepository;
  final ConnectionCubit _connectionCubit;

  ProfileCubit({
    required IProfileRepository profileRepository,
    required ConnectionCubit connectionCubit,
  })  : _profileRepository = profileRepository,
        _connectionCubit = connectionCubit,
        super(ProfileInitialState());

  void startListening() async {
    assert(state is ProfileInitialState);

    try {
      await for (final profile in _profileRepository.profileStream) {
        if (profile != null) {
          emit(ProfileExistsState(profile));
        } else {
          emit(NoProfileExistsState());
        }
      }
    } on PointsConnectionError {
      _connectionCubit.reportError();
    }
  }

  void updateProfile(
    String? name,
    String? status,
    String? bio,
    int? color,
    int? icon,
  ) async {
    assert(state is ProfileExistsState);

    try {
      await _profileRepository.updateAccount(
        name: name,
        status: status,
        bio: bio,
        color: color,
        icon: icon,
      );
    } on PointsConnectionError {
      _connectionCubit.reportError();
    }
  }

  @override
  Future<void> close() {
    _profileRepository.close();
    return super.close();
  }
}
