import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide NeumorphicAppBar;
import 'package:ionicons/ionicons.dart';
import 'package:points/helpers/uppercase_to_lowercase_text_input_formatter.dart';
import 'package:points/state_management/user_discovery_cubit.dart';
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/neumorphic_app_bar_fix.dart';
import 'package:points/widgets/neumorphic_loading_text_button.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:points/widgets/neumorphic_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:points/widgets/user_list_tile.dart';

class UserDiscoveryPage extends StatefulWidget {
  @override
  State<UserDiscoveryPage> createState() => _UserDiscoveryPageState();
}

class _UserDiscoveryPageState extends State<UserDiscoveryPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  Widget _buildTextField() {
    return NeumorphicTextField(
      controller: _controller,
      onSubmitted: (s) => _search(s),
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
      focusNode: _focusNode,
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
            if (_controller.text.isNotEmpty) {
              _controller.clear();
              context.read<UserDiscoveryCubit>().clear();
              _focusNode.requestFocus();
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

  Widget _buildUserList(UserDiscoveryResult state) {
    return ListView.builder(
      itemCount: state.result.length,
      itemBuilder: (item, index) {
        final userResult = state.result[index];
        final user = userResult.user;

        return UserListTile(
          name: user.name,
          status: user.status,
          color: user.color,
          icon: user.icon,
          points: user.points,
          onPressed:
              userResult.wasRequested ? null : () => _showUserActions(user.id),
        );
      },
    );
  }

  Widget _buildContent(UserDiscoveryState state) {
    if (state is UserDiscoveryNewQueryLoading) {
      return Loader();
    }
    if (state is UserDiscoveryEmptyResult) {
      return Text("No results found");
    }
    if (state is UserDiscoveryResult) {
      return _buildUserList(state);
    }
    if (state is UserDiscoveryError) {
      return Text(
        state.message,
        style: TextStyle(
          color: Theme.of(context).errorColor,
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
    if (state is UserDiscoveryInitial) {
      return SizedBox();
    }
    throw Exception("State not covered");
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserDiscoveryCubit, UserDiscoveryState>(
      buildWhen: (oldState, newState) {
        return newState is! UserDiscoveryLoadMoreLoading;
      },
      builder: (context, state) {
        final loading = state is UserDiscoveryNewQueryLoading;
        return IgnorePointer(
          ignoring: loading,
          child: NeumorphicScaffold(
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
                  loading: loading,
                  tooltip: "Search",
                  child: Icon(Ionicons.search_outline),
                  onPressed: () => _search(_controller.text),
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
            floatingActionButton: NeumorphicFloatingActionButton(
              child: Icon(Ionicons.home_outline),
              onPressed: () => Navigator.pop(context),
              style: NeumorphicStyle(
                depth: 8,
              ),
            ),
          ),
        );
      },
    );
  }

  void _search(String? searchTerm) {
    final userDiscoveryCubit = context.read<UserDiscoveryCubit>();

    if (searchTerm?.isEmpty != false) {
      searchTerm = null;
    }
    userDiscoveryCubit.query(nameQuery: searchTerm, sortByPopularity: false);
  }
}
