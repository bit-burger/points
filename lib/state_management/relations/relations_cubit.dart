import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:user_repositories/relations_repository.dart';
import '../../pages/relations/relations_sub_page.dart';
import '../../pages/give_points/give_points_page.dart';

part 'relations_state.dart';

/// Listens to and emits the [IRelationsRepository] to listen to the
/// friends, friend requests and blocked users (by and to the user).
///
/// Is also used to change relationships, these are supported operations:
///  - [request], [cancelRequest]
///  - [accept], [reject]
///  - [unfriend]
///  - [block], [unblock]
///
/// Used by multiple pages,
/// most importantly however in the [RelationsSubPage] and [GivePointsPage]
/// (in the [GivePointsPage however only the friends are listened to).
class RelationsCubit extends Cubit<RelationsState> {
  final IRelationsRepository _relationsRepository;
  final AuthCubit authCubit;

  RelationsCubit({
    required this.authCubit,
    required IRelationsRepository relationsRepository,
  })  : _relationsRepository = relationsRepository,
        super(RelationsInitialLoading());

  void startListening() async {
    try {
      await for (final relations in _relationsRepository.relationsStream) {
        emit(RelationsData(relations));
      }
    } on PointsError catch (_) {
      authCubit.reportConnectionError();
    }
  }

  void accept(String id) {
    _relationsRepository.accept(id);
  }

  void block(String id) {
    _relationsRepository.block(id);
  }

  void reject(String id) {
    _relationsRepository.reject(id);
  }

  void request(String id) {
    _relationsRepository.request(id);
  }

  void cancelRequest(String id) {
    _relationsRepository.cancelRequest(id);
  }

  void unblock(String id) {
    _relationsRepository.unblock(id);
  }

  void unfriend(String id) {
    _relationsRepository.unfriend(id);
  }

  @override
  Future<void> close() {
    _relationsRepository.close();
    return super.close();
  }
}
