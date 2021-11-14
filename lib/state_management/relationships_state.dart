part of 'relationships_cubit.dart';

@immutable
abstract class RelationshipsState {}

class RelationshipsInitialLoading extends RelationshipsState {}

class RelationshipsData extends RelationshipsState {
  final UserRelations userRelations;

  RelationshipsData(this.userRelations);
}
