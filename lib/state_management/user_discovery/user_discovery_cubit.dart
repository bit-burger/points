import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';

part 'user_discovery_state.dart';

/// Search for users, page the results, and request/block the users,
/// while keeping track of who has already been requested/blocked
class UserDiscoveryCubit extends Cubit<UserDiscoveryState> {
  static const _resultsPageLength = 20;

  final IUserDiscoveryRepository _userDiscoveryRepository;
  final IRelationsRepository _relationsRepository;
  final AuthCubit authCubit;

  UserDiscoveryCubit({
    required this.authCubit,
    required IUserDiscoveryRepository userDiscoveryRepository,
    required IRelationsRepository relationsRepository,
  })  : _userDiscoveryRepository = userDiscoveryRepository,
        _relationsRepository = relationsRepository,
        super(UserDiscoveryWaitingForUserInput());

  void request(String id) {
    assert(state is UserDiscoveryResult);

    _relationsRepository.request(id);
    _updateWasRequested(id);
  }

  void block(String id) {
    assert(state is UserDiscoveryResult);

    _relationsRepository.block(id);
    _updateWasRequested(id);
  }

  void _updateWasRequested(String id) {
    final state = this.state as UserDiscoveryResult;

    emit(
      UserDiscoveryResult(
        state.users.toList(),
        {...state.invitedUserIds, id},
        state.nextPage,
      ),
    );
  }

  void clear() {
    emit(UserDiscoveryWaitingForUserInput());
  }

  void awaitPages() {
    emit(UserDiscoveryAwaitingPages());
  }

  void addToPages({
    required String? nameQuery,
    required bool sortByPopularity,
    int pageIndex = 0,
  }) async {
    try {
      final previousUsers = (state as UserDiscoveryResult).users;

      final newUsers = (await _userDiscoveryRepository.queryUsers(
        nameQuery: nameQuery,
        sortByPopularity: sortByPopularity,
        pageIndex: pageIndex,
        pageLength: _resultsPageLength,
      ));

      final isLastPage = newUsers.length < _resultsPageLength;
      final nextPage = isLastPage ? null : pageIndex + 1;

      final combinedUsers = <User>[
        ...previousUsers,
        ...newUsers,
      ];

      assert(combinedUsers.map((user) => user.id).toSet().length ==
          combinedUsers.length);

      if (combinedUsers.isNotEmpty) {
        emit(
          UserDiscoveryResult(
            combinedUsers,
            (state as UserDiscoveryResult).invitedUserIds,
            nextPage,
          ),
        );
      } else {
        emit(UserDiscoveryEmptyResult());
      }
    } on PointsError {
      authCubit.reportConnectionError();
    }
  }
}
