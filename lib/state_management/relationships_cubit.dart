import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'relationships_state.dart';

class RelationshipsCubit extends Cubit<RelationshipsState> {
  RelationshipsCubit() : super(RelationshipsInitial());
}
