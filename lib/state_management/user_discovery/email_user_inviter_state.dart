part of 'email_user_inviter_cubit.dart';

@immutable
abstract class EmailUserInviterState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmailUserInviterInitial extends EmailUserInviterState {}

class EmailUserInviterNotValid extends EmailUserInviterError {
  EmailUserInviterNotValid() : super("Not a valid email");
}

class EmailUserInviterNotFound extends EmailUserInviterError {
  EmailUserInviterNotFound() : super("User not found");
}

class EmailUserInviterFoundUserIsAlreadyRelated extends EmailUserInviterError {
  EmailUserInviterFoundUserIsAlreadyRelated()
      : super("Already related with user");
}

class EmailUserInviterFoundUserIsSelf extends EmailUserInviterError {
  EmailUserInviterFoundUserIsSelf() : super("This is your own email");
}

abstract class EmailUserInviterError extends EmailUserInviterState {
  final String message;

  EmailUserInviterError(this.message);

  @override
  List<Object?> get props => [message];
}

class EmailUserInviterRequestLoading extends EmailUserInviterState {}

class EmailUserInviterFinished extends EmailUserInviterState {}
