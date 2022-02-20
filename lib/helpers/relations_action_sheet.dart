import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:points/state_management/relations/relations_cubit.dart';

class _RelationSheetAction extends SheetAction<String> {
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

/// Shows an [ActionSheet], for relation actions for a specific user,
/// that are then applied to RelationsCubit.
///
/// Custom Actions can also be given and handled.
void showRelationsActionSheet({
  required BuildContext context,
  String? title,
  required List<SheetAction> actions,
  String? userId,
  void Function(String)? alternativeResultCallback,
}) async {
  final relationsCubit = context.read<RelationsCubit>();
  final result = await showModalActionSheet(
    context: context,
    title: title,
    actions: actions,
  );
  if (userId != null) {
    switch (result) {
      case "accept":
        relationsCubit.accept(userId);
        break;
      case "block":
        relationsCubit.block(userId);
        break;
      case "cancel_request":
        relationsCubit.cancelRequest(userId);
        break;
      case "reject":
        relationsCubit.reject(userId);
        break;
      case "request":
        relationsCubit.request(userId);
        break;
      case "unblock":
        relationsCubit.unblock(userId);
        break;
      case "unfriend":
        relationsCubit.unfriend(userId);
        break;
      case null:
        break;
      default:
        if (alternativeResultCallback != null) {
          alternativeResultCallback(result);
          break;
        }
        throw Exception("Not a valid _RelationSheetAction");
    }
  } else {
    alternativeResultCallback!.call(result);
  }
}
