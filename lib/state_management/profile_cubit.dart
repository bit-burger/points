import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:points_repositories/points_repositories.dart';

import 'connection_cubit.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final IPointsProfileRepository _profileRepository;
  final ConnectionCubit _connectionCubit;

  ProfileCubit({
    required IPointsProfileRepository profileRepository,
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

  void createProfile(String name) async {
    assert(state is NoProfileExistsState);

    emit(ProfileLoadingState());
    try {
      await _profileRepository.createAccount(name);
    } on PointsConnectionError {
      _connectionCubit.reportError();
    }
  }

  void deleteProfile() async {
    assert(state is ProfileExistsState);

    emit(ProfileLoadingState());
    try {
      await _profileRepository.deleteAccount();
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
