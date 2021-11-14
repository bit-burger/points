part of 'relations_cubit.dart';

@immutable
abstract class RelationsState {}

class RelationsInitialLoading extends RelationsState {}

class RelationsData extends RelationsState {
  final UserRelations userRelations;

  RelationsData(this.userRelations);
}
