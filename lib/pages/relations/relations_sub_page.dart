import 'dart:io' show Platform;

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:points/helpers/relations_action_sheet.dart';
import 'package:points/state_management/relations/relations_cubit.dart';
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/user_list_tile.dart';
import 'package:user_repositories/relations_repository.dart';

class RelationsSubPage extends StatefulWidget {
  @override
  State<RelationsSubPage> createState() => _RelationsSubPageState();
}

class _RelationsSubPageState extends State<RelationsSubPage> {
  bool _showBlocked = false;

  void _toggleShowBlocked() {
    setState(() {
      _showBlocked = !_showBlocked;
    });
  }

  Iterable<Widget> _listViewFromUsers({
    required List<User> users,
    String? name,
    String? key,
    void Function(User user)? onPressed,
    void Function(User user)? onLongPressed,
    Future<bool> Function(User user)? confirmDismiss,
    void Function(User user)? onDismissed,
  }) sync* {
    assert((name != null) != (key != null));
    if (users.isNotEmpty) {
      if (name != null) {
        yield Padding(
          padding: EdgeInsets.only(left: 28),
          child: Text(
            name,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                color: Theme.of(context).hintColor,
                fontWeight: FontWeight.bold),
          ),
        );
      }
      yield AnimatedSwitcher(
        duration: Duration(milliseconds: 250),
        child: ListView.builder(
          key: UniqueKey(),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (item, index) {
            final user = users[index];
            Widget widget = UserListTile(
              name: user.name,
              status: user.status,
              color: user.color,
              icon: user.icon,
              points: user.points,
              onPressed: () => onPressed?.call(user),
              onLongPressed: () {
                (onLongPressed ?? onPressed)?.call(user);
              },
              margin: EdgeInsets.symmetric(horizontal: 16).copyWith(
                top: 8,
                bottom: 24,
              ),
            );
            if (onDismissed != null) {
              widget = Dismissible(
                key: ValueKey(user.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => onDismissed(user),
                confirmDismiss:
                    confirmDismiss == null ? null : (_) => confirmDismiss(user),
                child: widget,
              );
            }
            return widget;
          },
        ),
      );
    }
  }

  Widget _buildRelationsListView(UserRelations relations) {
    return ListView(
      key: ValueKey("relations"),
      physics: Platform.isIOS
          ? BouncingScrollPhysics(parent: ClampingScrollPhysics())
          : null,
      children: [
        ..._listViewFromUsers(
          users: relations.friends,
          key: "friends",
          onLongPressed: (user) async {
            showRelationsActionSheet(
              context: context,
              actions: [
                unfriendAction,
                blockAction,
              ],
              userId: user.id,
            );
          },
          confirmDismiss: (user) async {
            final result = await showOkCancelAlertDialog(
              context: context,
              title: "Warning",
              message: "Do you want to unfriend '${user.name}'?",
              isDestructiveAction: true,
            );

            return result == OkCancelResult.ok;
          },
          onDismissed: (user) async {
            context.read<RelationsCubit>().unfriend(user.id);
          },
        ),
        ..._listViewFromUsers(
            name: "requests",
            users: relations.requests,
            onPressed: (user) {
              showRelationsActionSheet(
                context: context,
                actions: [
                  acceptAction,
                  rejectAction,
                  blockAction,
                ],
                userId: user.id,
              );
            },
            onDismissed: (user) {
              context.read<RelationsCubit>().reject(user.id);
            }),
        ..._listViewFromUsers(
          name: "pending",
          users: relations.pending,
          onPressed: (user) {
            showRelationsActionSheet(
              context: context,
              actions: [
                cancelAction,
                blockAction,
              ],
              userId: user.id,
            );
          },
          onDismissed: (user) {
            context.read<RelationsCubit>().cancelRequest(user.id);
          },
        ),
        if (_showBlocked)
          ..._listViewFromUsers(
            name: "blocked",
            users: relations.blocked,
            onPressed: (user) {
              showRelationsActionSheet(
                context: context,
                actions: [
                  unblockAction,
                ],
                userId: user.id,
              );
            },
            confirmDismiss: (user) async {
              final result = await showOkCancelAlertDialog(
                context: context,
                title: "Warning",
                message: "Do you want to unblock '${user.name}'?",
                isDestructiveAction: true,
              );

              return result == OkCancelResult.ok;
            },
            onDismissed: (user) async {
              context.read<RelationsCubit>().unblock(user.id);
            },
          ),
        if (_showBlocked)
          ..._listViewFromUsers(
            name: "blocked by",
            users: relations.blockedBy,
          ),
        Column(
          children: _buildShowBlocksButton(relations).toList(),
        ),
      ],
    );
  }

  Iterable<Widget> _buildShowBlocksButton(UserRelations relations) sync* {
    if (relations.blockedRelationsCount > 0) {
      yield SizedBox(height: 16);
      if (_showBlocked) {
        yield NeumorphicButton(
          child: Text("Hide blocked users"),
          onPressed: _toggleShowBlocked,
        );
      } else {
        yield NeumorphicButton(
          child: Text("Show blocked users"),
          onPressed: _toggleShowBlocked,
        );
      }
      yield SizedBox(height: 24);
    }
  }

  Widget _buildContent(RelationsState state) {
    if (state is RelationsInitialLoading) {
      return Center(key: ValueKey("loading"), child: Loader());
    }
    final relations = (state as RelationsData).userRelations;
    final relationsCount = _showBlocked
        ? relations.relationsCount
        : relations.normalRelationsCount;
    final blockedRelationsCount = relations.blockedRelationsCount;

    if (relationsCount == 0) {
      var text = "No friends :(";
      if (blockedRelationsCount == 0) {
        text = "No friends and blocks :(";
      }
      _buildShowBlocksButton(relations);
      return Center(
        key: ValueKey(text),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(color: Theme.of(context).hintColor),
                ),
              ),
            ),
            ..._buildShowBlocksButton(relations),
          ],
        ),
      );
    }
    return _buildRelationsListView(relations);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RelationsCubit, RelationsState>(
      listenWhen: (oldState, newState) {
        // if there are no blocked relations anymore toggle blocked
        if (oldState is! RelationsData || newState is! RelationsData) {
          return false;
        }
        return oldState.userRelations.blockedRelationsCount > 0 &&
            newState.userRelations.blockedRelationsCount == 0 &&
            _showBlocked;
      },
      listener: (context, state) => _toggleShowBlocked(),
      builder: (_, state) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          child: _buildContent(state),
        );
      },
    );
  }
}
