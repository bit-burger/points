import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:user_repositories/relations_repository.dart';

part 'relationships_state.dart';

class RelationshipsCubit extends Cubit<RelationshipsState> {
  final IRelationsRepository _relationsRepository;

  RelationshipsCubit({
    required IRelationsRepository relationsRepository,
  })  : _relationsRepository = relationsRepository,
        super(RelationshipsInitialLoading());

  void startListening() async {
    await for (final relations in _relationsRepository.relationsStream) {
      emit(RelationshipsData(relations));
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
