import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:user_repositories/profile_repository.dart';

part 'profile_state.dart';

/// Listens to the [IProfileRepository.profileStream],
/// for the profile data of the current user.
///
/// Used in multiple pages.
class ProfileCubit extends Cubit<ProfileState> {
  final IProfileRepository _profileRepository;
  final AuthCubit _authCubit;

  ProfileCubit({
    required IProfileRepository profileRepository,
    required AuthCubit connectionCubit,
  })  : _profileRepository = profileRepository,
        _authCubit = connectionCubit,
        super(ProfileInitialState());

  void startListening() async {
    assert(state is ProfileInitialState);

    try {
      await for (final profile in _profileRepository.profileStream) {
        emit(ProfileExistsState(profile));
      }
    } on PointsConnectionError {
      _authCubit.reportConnectionError();
    }
  }

  @override
  Future<void> close() {
    _profileRepository.close();
    return super.close();
  }
}
