import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:user_repositories/relations_repository.dart';

part 'relations_state.dart';

class RelationsCubit extends Cubit<RelationsState> {
  final IRelationsRepository _relationsRepository;

  RelationsCubit({
    required IRelationsRepository relationsRepository,
  })  : _relationsRepository = relationsRepository,
        super(RelationsInitialLoading());

  void startListening() async {
    await for (final relations in _relationsRepository.relationsStream) {
      emit(RelationsData(relations));
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
