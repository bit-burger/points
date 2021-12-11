import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide NeumorphicAppBar;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';
import 'package:points/helpers/uppercase_to_lowercase_text_input_formatter.dart';
import 'package:points/pages/user_discovery/invite_popup.dart';
import 'package:points/state_management/user_discovery/user_discovery_cubit.dart';
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/neumorphic_app_bar_fix.dart';
import 'package:points/widgets/neumorphic_loading_text_button.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:points/widgets/neumorphic_text_field.dart';
import 'package:points/widgets/user_list_tile.dart';
import 'package:user_repositories/user_discovery_repository.dart';
import '../../theme/points_colors.dart' as colors;

class UserDiscoveryPage extends StatefulWidget {
  @override
  State<UserDiscoveryPage> createState() => _UserDiscoveryPageState();
}

class _UserDiscoveryPageState extends State<UserDiscoveryPage> {
  final _searchTextController = TextEditingController();
  final _searchFocusNode = FocusNode();

  final _pagingController = PagingController<int, User>(
    firstPageKey: 0,
  );

  Widget _buildTextField() {
    return NeumorphicTextField(
      controller: _searchTextController,
      onSubmitted: (_) => _search(),
      onChanged: (s) {
        context.read<UserDiscoveryCubit>().clear();
      },
      inputFormatters: [
        LengthLimitingTextInputFormatter(8),
        UppercaseToLowercaseTextInputFormatter(),
      ],
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.stadium(),
        intensity: 0.7,
        depth: 8,
      ),
      focusNode: _searchFocusNode,
      hintText: "search...",
      textInputAction: TextInputAction.search,
      trailing: SizedBox(
        width: 24,
        child: TextButton(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            foregroundColor: MaterialStateProperty.resolveWith(
              (state) {
                if (state.contains(MaterialState.pressed)) {
                  return Colors.grey[400];
                }
                return Colors.grey[600];
              },
            ),
            padding: MaterialStateProperty.all(EdgeInsets.zero),
          ),
          child: Icon(Ionicons.close_outline),
          onPressed: () {
            if (_searchTextController.text.isNotEmpty) {
              _searchTextController.clear();
              context.read<UserDiscoveryCubit>().clear();
              _searchFocusNode.requestFocus();
            }
          },
        ),
      ),
    );
  }

  void _showUserActions(String userId) async {
    final result = await showModalActionSheet(
      context: context,
      actions: [
        SheetAction(
          label: "Request friendship",
          key: "request",
        ),
        SheetAction(
          label: "Block",
          key: "block",
        ),
      ],
    );
    final cubit = context.read<UserDiscoveryCubit>();
    switch (result) {
      case "request":
        cubit.request(userId);
        break;
      case "block":
        cubit.block(userId);
        break;
    }
  }

  Widget _buildUserList() {
    return PagedListView<int, User>(
      padding: MediaQuery.of(context).padding.add(EdgeInsets.only(
            top: 80,
            bottom: 80,
          )),
      builderDelegate: PagedChildBuilderDelegate(
        animateTransitions: true,
        firstPageProgressIndicatorBuilder: (_) => Loader(),
        newPageProgressIndicatorBuilder: (_) => Loader(),
        itemBuilder: (context, user, index) {
          return UserListTile(
            name: user.name,
            status: user.status,
            color: user.color,
            icon: user.icon,
            points: user.points,
            onPressed: (context.read<UserDiscoveryCubit>().state
                        as UserDiscoveryResult)
                    .invitedUserIds
                    .contains(user.id)
                ? null
                : () => _showUserActions(user.id),
          );
        },
      ),
      pagingController: _pagingController,
    );
  }

  Widget _buildContent(UserDiscoveryState state) {
    if (state is UserDiscoveryEmptyResult) {
      return Center(
        child: Text(
          "No matching results found",
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).hintColor,
          ),
        ),
      );
    }
    if (state is UserDiscoveryWaitingForUserInput) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Loader(),
          SizedBox(height: 16),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Press enter or ",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).hintColor,
                ),
              ),
              Icon(
                Ionicons.search_outline,
                color: Theme.of(context).hintColor,
              ),
            ],
          ),
        ],
      );
    }
    return _buildUserList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserDiscoveryCubit, UserDiscoveryState>(
      listener: (context, state) {
        if (state is UserDiscoveryResult) {
          _pagingController.value = PagingState(
            nextPageKey: state.nextPage,
            itemList:
                (state is UserDiscoveryAwaitingPages) ? null : state.users,
          );
        }
      },
      buildWhen: (oldState, newState) =>
          oldState is! UserDiscoveryResult || newState is! UserDiscoveryResult,
      builder: (context, state) {
        return NeumorphicScaffold(
          appBar: NeumorphicAppBar(
            title: Padding(
              padding: EdgeInsets.only(right: 12),
              child: _buildTextField(),
            ),
            middleSpacing: false,
            centerTitle: false,
            trailing: Hero(
              tag: "User search",
              child: NeumorphicLoadingTextButton(
                tooltip: "Search",
                child: Icon(Ionicons.search_outline),
                onPressed: _search,
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.circle(),
                  intensity: 0.7,
                  depth: 8,
                ),
              ),
            ),
          ),
          extendBodyBehindAppBar: true,
          body: Center(
            child: AnimatedSwitcher(
              duration: Duration(
                milliseconds: 400,
              ),
              child: _buildContent(state),
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              NeumorphicFloatingActionButton(
                child: Icon(Ionicons.person_add_outline),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  barrierColor: colors.barrierColor,
                  backgroundColor: Colors.transparent,
                  builder: (_) => InvitePopup(),
                ),
                style: NeumorphicStyle(
                  depth: 8,
                ),
              ),
              SizedBox(height: 16),
              NeumorphicFloatingActionButton(
                child: Icon(Ionicons.home_outline),
                onPressed: () => Navigator.pop(context),
                style: NeumorphicStyle(
                  depth: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _search() {
    final userDiscoveryCubit = context.read<UserDiscoveryCubit>();

    userDiscoveryCubit.awaitPages();
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((nextPage) {
      String? searchTerm = _searchTextController.text;
      if (searchTerm.isEmpty) {
        searchTerm = null;
      }
      context.read<UserDiscoveryCubit>().addToPages(
            pageIndex: nextPage,
            nameQuery: searchTerm,
            sortByPopularity: false,
          );
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
