import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:user_repositories/user_discovery_repository.dart';

part 'user_discovery_state.dart';

class UserDiscoveryCubit extends Cubit<UserDiscoveryState> {
  static const _resultsPageLength = 25;

  final IUserDiscoveryRepository _userDiscoveryRepository;

  late String? lastNameQuery;
  late bool lastSortByPopularity;

  UserDiscoveryCubit({
    required IUserDiscoveryRepository userDiscoveryRepository,
  })  : _userDiscoveryRepository = userDiscoveryRepository,
        super(UserDiscoveryInitial());

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
    List<User> previousResult = const [],
  }) async {
    try {
      final result = await _userDiscoveryRepository.queryUsers(
        nameQuery: nameQuery,
        sortByPopularity: sortByPopularity,
        pageLength: _resultsPageLength,
      );

      final isLastPage = result.length < _resultsPageLength;

      final combinedNewResult = [...previousResult, ...result];

      if (combinedNewResult.isEmpty) {
        emit(UserDiscoveryEmptyResult());
      } else {
        emit(UserDiscoveryResult(result, isLastPage));
      }
    } on PointsError catch (e) {
      emit(UserDiscoveryError(e.message));
    }
  }
}
