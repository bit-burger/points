import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide NeumorphicAppBar;
import 'package:ionicons/ionicons.dart';
import 'package:points/pages/relations/relations_sub_page.dart';
import 'package:points/state_management/notifications/notification_unread_count_cubit.dart';
import 'package:points/state_management/profile/profile_cubit.dart';
import 'package:points/state_management/relations/relations_cubit.dart';
import 'package:points/theme/points_colors.dart';
import 'package:points/widgets/neumorphic_app_bar_fix.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:points/widgets/points_logo.dart';
import 'package:user_repositories/profile_repository.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';
import '../../widgets/speed_dial.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  Widget _buildMenuDial() {
    return NeumorphicSpeedDial(
      controller: _animationController,
      child: Center(
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animationController.view,
        ),
      ),
      speedDialChildren: [
        SpeedDialChild(
          icon: Center(
            child: PointsLogo(
              size: 24,
            ),
          ),
          label: "points",
          onPressed: () {
            // Navigate to points screen
          },
        ),
        SpeedDialChild(
          icon: Icon(Ionicons.settings_outline),
          label: "settings",
          onPressed: () {
            Navigator.of(context).pushNamed("/profile");
          },
        ),
        SpeedDialChild(
          icon: Icon(Ionicons.information_circle_outline),
          label: "info",
          onPressed: () {
            Navigator.of(context).pushNamed("/info");
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RelationsCubit, RelationsState>(
      buildWhen: (oldState, newState) {
        return oldState is RelationsInitialLoading ||
            newState is RelationsInitialLoading;
      },
      builder: (context, relationsState) {
        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            bool isLoading = profileState is ProfileLoadingState ||
                relationsState is RelationsInitialLoading;
            User? rootUser;
            if (profileState is ProfileExistsState) {
              rootUser = profileState.profile;
            }
            return IgnorePointer(
              ignoring: isLoading,
              child: Stack(
                children: [
                  NeumorphicScaffold(
                    extendBodyBehindAppBar: true,
                    appBar: NeumorphicAppBar(
                      title: AnimatedSwitcher(
                        duration: Duration(milliseconds: 250),
                        child: Text(
                          rootUser?.name ?? "...",
                          key: ValueKey(rootUser),
                        ),
                      ),
                      leading: Hero(
                        tag: "User search",
                        transitionOnUserGestures: true,
                        child: NeumorphicButton(
                          tooltip: "Search for users",
                          child: Icon(Ionicons.search_outline),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              "/user-discovery",
                            );
                          },
                          style: NeumorphicStyle(
                            boxShape: NeumorphicBoxShape.circle(),
                          ),
                        ),
                      ),
                      trailing: BlocBuilder<NotificationUnreadCountCubit, int>(
                        builder: (context, unreadCount) {
                          return Badge(
                            showBadge: unreadCount > 0,
                            position: BadgePosition(
                              end: -6,
                              top: -6,
                            ),
                            badgeColor: white,
                            badgeContent: Text(unreadCount.toString()),
                            child: NeumorphicButton(
                              tooltip: "Notifications",
                              child: SizedBox.fromSize(
                                size: Size.square(56),
                                child: Icon(Ionicons.notifications_outline),
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed("/notifications");
                              },
                              style: NeumorphicStyle(
                                boxShape: NeumorphicBoxShape.circle(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    body: RelationsSubPage(),
                  ),
                  AnimatedBuilder(
                    animation: _animationController.view,
                    child: GestureDetector(
                      onTap: () {
                        _animationController.reverse();
                      },
                      child: Container(color: barrierColor),
                    ),
                    builder: (context, child) {
                      if (_animationController.isDismissed) {
                        return SizedBox();
                      }
                      return Opacity(
                        opacity: _animationController.value,
                        child: child,
                      );
                    },
                  ),
                  Positioned(
                    right: 16,
                    bottom: MediaQuery.of(context).viewPadding.bottom + 16,
                    child: Material(
                      color: Colors.transparent,
                      child: _buildMenuDial(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 250),
      vsync: this,
    );
    super.initState();
  }
}
