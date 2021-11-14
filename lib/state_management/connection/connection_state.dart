part of 'connection_cubit.dart';

@immutable
abstract class ConnectionState {}

class ConnectionWorkingState extends ConnectionState {}

class ConnectionFailedState extends ConnectionState {}
