import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';

part 'user_discovery_state.dart';

class UserDiscoveryCubit extends Cubit<UserDiscoveryState> {
  static const _resultsPageLength = 20;

  final IUserDiscoveryRepository _userDiscoveryRepository;
  final IRelationsRepository _relationsRepository;

  UserDiscoveryCubit({
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
    final users = state.result.toList();

    final i = users.indexWhere((userResult) => userResult.user.id == id);
    final userResult = users.removeAt(i);
    users.insert(i, UserResult(userResult.user, true));

    emit(UserDiscoveryResult(users, state.nextPage));
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
      final previousResult = (state as UserDiscoveryResult).result;

      final newUsers = (await _userDiscoveryRepository.queryUsers(
        nameQuery: nameQuery,
        sortByPopularity: sortByPopularity,
        pageIndex: pageIndex,
        pageLength: _resultsPageLength,
      ));

      final newUserResults = newUsers
          .map((user) => UserResult(user, false))
          .toList(growable: false);

      assert(newUserResults
              .map((userResult) => userResult.user.id)
              .toSet()
              .length ==
          newUserResults.length);

      final isLastPage = newUsers.length < _resultsPageLength;
      final nextPage = isLastPage ? null : pageIndex + 1;

      final combinedNewResult = <UserResult>[
        ...previousResult,
        ...newUserResults
      ];

      if (combinedNewResult.isNotEmpty) {
        emit(UserDiscoveryResult(combinedNewResult, nextPage));
      } else {
        emit(UserDiscoveryEmptyResult());
      }
    } on PointsError catch (e) {
      emit(UserDiscoveryError(e.message));
    }
  }
}
