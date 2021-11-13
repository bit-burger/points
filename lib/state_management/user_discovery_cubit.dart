import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';

part 'user_discovery_state.dart';

class UserDiscoveryCubit extends Cubit<UserDiscoveryState> {
  static const _resultsPageLength = 20;

  final IUserDiscoveryRepository _userDiscoveryRepository;
  final IRelationsRepository _relationsRepository;

  late String? lastNameQuery;
  late bool lastSortByPopularity;

  UserDiscoveryCubit({
    required IUserDiscoveryRepository userDiscoveryRepository,
    required IRelationsRepository relationsRepository,
  })  : _userDiscoveryRepository = userDiscoveryRepository,
        _relationsRepository = relationsRepository,
        super(UserDiscoveryInitial());

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

    emit(UserDiscoveryResult(users, state.isLast));
  }

  void query({
    String? nameQuery,
    bool sortByPopularity = false,
  }) async {
    emit(UserDiscoveryNewQueryLoading());

    await _query(
      nameQuery: nameQuery,
      sortByPopularity: sortByPopularity,
    );
  }

  void clear() {
    emit(UserDiscoveryWaitingForUserInput());
  }

  void loadMore() async {
    assert(state is UserDiscoveryResult);
    assert(!(state as UserDiscoveryResult).isLast);

    final lastResult = (state as UserDiscoveryResult).result;

    final pageIndex = lastResult.length ~/ _resultsPageLength;

    emit(UserDiscoveryLoadMoreLoading());

    await _query(
      nameQuery: lastNameQuery,
      sortByPopularity: lastSortByPopularity,
      pageIndex: pageIndex,
      previousResult: lastResult,
    );
  }

  Future<void> _query({
    required String? nameQuery,
    required bool sortByPopularity,
    int pageIndex = 0,
    List<UserResult> previousResult = const [],
  }) async {
    try {
      final newUsers = (await _userDiscoveryRepository.queryUsers(
        nameQuery: nameQuery,
        sortByPopularity: sortByPopularity,
        pageLength: _resultsPageLength,
      ));

      final newUserResults = newUsers
          .map((user) => UserResult(user, false))
          .toList(growable: false);

      final isLastPage = newUsers.length < _resultsPageLength;

      final combinedNewResult = <UserResult>[
        ...previousResult,
        ...newUserResults
      ];

      if (combinedNewResult.isEmpty) {
        emit(UserDiscoveryEmptyResult());
      } else {
        emit(UserDiscoveryResult(newUserResults, isLastPage));
      }
    } on PointsError catch (e) {
      emit(UserDiscoveryError(e.message));
    }
  }
}
