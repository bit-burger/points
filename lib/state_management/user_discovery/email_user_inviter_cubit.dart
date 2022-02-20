import 'package:auth_repository/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';
import 'package:equatable/equatable.dart';
import '../../pages/user_discovery/invite_popup.dart';

part 'email_user_inviter_state.dart';

/// For the [InvitePopup] to friend request a user by their email.
///
///
class EmailUserInviterCubit extends Cubit<EmailUserInviterState> {
  final AuthCubit authCubit;
  final UserDiscoveryRepository _userDiscoveryRepository;
  final RelationsRepository _relationsRepository;
  final AccountCredentials _credentials;

  EmailUserInviterCubit({
    required this.authCubit,
    required UserDiscoveryRepository userDiscoveryRepository,
    required RelationsRepository relationsRepository,
  })  : _credentials = (authCubit.state as LoggedInState).credentials,
        _userDiscoveryRepository = userDiscoveryRepository,
        _relationsRepository = relationsRepository,
        super(EmailUserInviterInitial());

  /// Emit error if the user is not found, if it is the own account,
  /// or if the current user is already related with that user.
  ///
  /// Emit the [EmailUserInviterFinished] state,
  /// if the invite has been successful.
  void requestUser(String email) async {
    emit(EmailUserInviterRequestLoading());
    try {
      final foundUser =
      await _userDiscoveryRepository.getUserByEmail(email: email);
      if (foundUser == null) {
        emit(EmailUserInviterNotFound());
      } else {
        final relationsAlreadyExists = _relationsRepository
            .currentUserRelations!.all
            .indexWhere((user) => user.id == foundUser.id) !=
            -1;
        final isSelf = _credentials.email == email;
        if (relationsAlreadyExists) {
          emit(EmailUserInviterFoundUserIsAlreadyRelated());
        } else if (isSelf) {
          emit(EmailUserInviterFoundUserIsSelf());
        } else {
          _relationsRepository.request(foundUser.id);
          emit(EmailUserInviterFinished());
        }
      }
    } on PointsConnectionError {
      authCubit.reportConnectionError();
    }
  }
}
