import 'package:auth_repository/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';
import 'package:async/async.dart';
import '../../helpers/reg_exp.dart' as regExp;
import 'package:equatable/equatable.dart';

part 'email_user_inviter_state.dart';

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

  void reset() {
    emit(EmailUserInviterInitial());
  }

  void requestUser() async {
    assert(state is EmailUserInviterFound);

    _relationsRepository.request((state as EmailUserInviterFound).userId);

    emit(EmailUserInviterRequestLoading());

    final relationsQueue = StreamQueue(_relationsRepository.relationsStream);
    try {
      await relationsQueue.next;
      emit(EmailUserInviterFinished());
    } on PointsConnectionError {
      authCubit.reportConnectionError();
    }
  }

  void updateSearchQuery({required String searchQuery}) {
    if (searchQuery.isEmpty) {
      emit(EmailUserInviterInitial());
    } else if (!regExp.email.hasMatch(searchQuery)) {
      emit(EmailUserInviterNotValid());
    } else {
      _searchForUser(searchQuery);
    }
  }

  void _searchForUser(String email) async {
    emit(EmailUserInviterLoading());
    try {
      final foundUser =
          await _userDiscoveryRepository.getUserByEmail(email: email);
      if (foundUser == null) {
        emit(EmailUserInviterNotFound());
      } else {
        _handleUserExists(foundUser, email);
      }
    } on PointsConnectionError {
      authCubit.reportConnectionError();
    }
  }

  void _handleUserExists(User foundUser, String email) {
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
      emit(EmailUserInviterFound(foundUser.id));
    }
  }
}
