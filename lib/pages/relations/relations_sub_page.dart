import 'dart:io' show Platform;

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:points/helpers/relations_action_sheet.dart';
import 'package:points/state_management/relations/relations_cubit.dart';
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/user_list_tile.dart';
import 'package:user_repositories/relations_repository.dart';
import '../home/home_navigator.dart';
import '../friend/friend_page.dart';

/// Lists and updates all related users (friends, requests, blocked).
///
/// Implement swiping, clicking and long click.
/// For example: Click on a friend and via [HomeNavigator]
/// get a [FriendPage] shown, press long
/// and get a SheetAction to unfriend or block the user,
/// swipe Left and be asked if the user wants to unfriend the friend.
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
    required List<RelatedUser> users,
    String? name,
    String? key,
    void Function(RelatedUser user)? onPressed,
    void Function(RelatedUser user)? onLongPressed,
    Future<bool> Function(RelatedUser user)? confirmDismiss,
    void Function(RelatedUser user)? onDismissed,
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
          key: ValueKey(users),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (item, index) {
            final user = users[index];
            Widget widget = IgnorePointer(
              ignoring: onPressed == null && onLongPressed == null,
              child: UserListTile(
                name: user.name,
                status: user.status,
                color: user.color,
                icon: user.icon,
                points: user.points,
                onPressed: () => onPressed?.call(user),
                onLongPressed: onLongPressed == null && onPressed == null
                    ? null
                    : () {
                        (onLongPressed ?? onPressed)!.call(user);
                      },
                margin: EdgeInsets.symmetric(horizontal: 16).copyWith(
                  top: 8,
                  bottom: 24,
                ),
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
    // Will look if the relations
    // or the _showBlocked have changed,
    // that their needs to be a animation
    // of the main ListView
    final blockedValue = Object.hash(
      relations.blocked.length.clamp(0, 1),
      relations.blockedBy.length.clamp(0, 1),
    );
    final value = Object.hash(
      relations.friends.length.clamp(0, 1),
      relations.pending.length.clamp(0, 1),
      relations.requests.length.clamp(0, 1),
      _showBlocked,
      _showBlocked ? blockedValue : 0,
    );
    return ListView(
      key: ValueKey(value),
      physics: Platform.isIOS
          ? BouncingScrollPhysics(parent: ClampingScrollPhysics())
          : null,
      children: [
        ..._listViewFromUsers(
          users: relations.friends,
          key: "friends",
          onPressed: (user) async {
            Navigator.of(context).pushNamed("/friend/${user.id}");
          },
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
            onPressed: (user) {
              showRelationsActionSheet(
                context: context,
                actions: [
                  blockAction,
                ],
                userId: user.id,
              );
            },
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

    if (relationsCount == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  "No friends :(",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(color: Theme.of(context).hintColor),
                ),
              ),
            ),
            SizedBox(height: 16),
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
