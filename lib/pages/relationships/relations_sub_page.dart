import 'dart:io' show Platform;

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:points/helpers/relation_action_sheet.dart';
import 'package:points/state_management/relationships_cubit.dart';
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/user_list_tile.dart';
import 'package:user_repositories/relations_repository.dart';

class RelationsSubPage extends StatefulWidget {
  @override
  State<RelationsSubPage> createState() => _RelationsSubPageState();
}

class _RelationsSubPageState extends State<RelationsSubPage> {
  Iterable<Widget> _listViewFromUsers({
    required List<User> users,
    String? name,
    String? key,
    void Function(User user)? onPressed,
    void Function(User user)? onLongPressed,
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
            showRelationActionSheet(
              context: context,
              actions: [
                unfriendAction,
                blockAction,
              ],
              userId: user.id,
            );
          },
          onDismissed: (user) async {
            final result = await showOkCancelAlertDialog(
              context: context,
              title: "Warning",
              message: "Do you want to unfriend '${user.name}'?",
              isDestructiveAction: true,
            );

            if (result == OkCancelResult.ok) {
              context.read<RelationshipsCubit>().unfriend(user.id);
            }
          },
        ),
        ..._listViewFromUsers(
            name: "requests",
            users: relations.requests,
            onPressed: (user) {
              showRelationActionSheet(
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
              context.read<RelationshipsCubit>().reject(user.id);
            }),
        ..._listViewFromUsers(
          name: "pending",
          users: relations.pending,
          onPressed: (user) {
            showRelationActionSheet(
              context: context,
              actions: [
                cancelAction,
                blockAction,
              ],
              userId: user.id,
            );
          },
          onDismissed: (user) {
            context.read<RelationshipsCubit>().cancelRequest(user.id);
          },
        ),
      ],
    );
  }

  Widget _buildContent(RelationshipsState state) {
    if (state is RelationshipsInitialLoading) {
      return Center(key: ValueKey("loading"), child: Loader());
    }
    final relations = (state as RelationshipsData).userRelations;
    final normalRelationsCount = relations.friends.length +
        relations.requests.length +
        relations.pending.length;
    if (normalRelationsCount == 0) {
      return Center(
        key: ValueKey("no relations"),
        child: Text(
          "No friends :(",
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Theme.of(context).hintColor),
        ),
      );
    }
    return _buildRelationsListView(relations);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RelationshipsCubit, RelationshipsState>(
      builder: (_, state) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          child: _buildContent(state),
        );
      },
    );
  }
}
