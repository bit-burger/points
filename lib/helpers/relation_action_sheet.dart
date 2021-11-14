import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:points/state_management/relationships_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _RelationSheetAction extends SheetAction {
  _RelationSheetAction({
    required String label,
    required String key,
  }) : super(label: label, key: key);
}

final acceptAction = _RelationSheetAction(
  label: "Accept the request",
  key: "accept",
);
final blockAction = _RelationSheetAction(
  label: "Block",
  key: "block",
);
final cancelAction = _RelationSheetAction(
  label: "Cancel friend request",
  key: "cancel_request",
);
final rejectAction = _RelationSheetAction(
  label: "Reject the request",
  key: "reject",
);
final requestAction = _RelationSheetAction(
  label: "Send friend request",
  key: "request",
);
final unblockAction = _RelationSheetAction(
  label: "Unblock",
  key: "unblock",
);
final unfriendAction = _RelationSheetAction(
  label: "Unfriend",
  key: "unfriend",
);

void showRelationActionSheet({
  required BuildContext context,
  required List<_RelationSheetAction> actions,
  required String userId,
}) async {
  final relationshipsCubit = context.read<RelationshipsCubit>();
  final result = await showModalActionSheet(context: context, actions: actions);
  switch (result) {
    case "accept":
      relationshipsCubit.accept(userId);
      break;
    case "block":
      relationshipsCubit.block(userId);
      break;
    case "cancel_request":
      relationshipsCubit.cancelRequest(userId);
      break;
    case "reject":
      relationshipsCubit.reject(userId);
      break;
    case "request":
      relationshipsCubit.request(userId);
      break;
    case "unblock":
      relationshipsCubit.unblock(userId);
      break;
    case "unfriend":
      relationshipsCubit.unfriend(userId);
      break;
    case null:
      break;
    default:
      throw Exception("Not a valid _RelationSheetAction");
  }
}
