import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Widget _buildUserList(UserDiscoveryResult state) {
    return ListView.builder(
      itemCount: state.result.length,
      itemBuilder: (item, index) {
        final user = state.result[index];
        return UserListTile(
          name: user.name,
          status: user.status,
          color: user.color,
          icon: user.icon,
          points: user.points,
          onPressed: () {},
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
                child: NeumorphicTextField(
                  controller: _controller,
                  onSubmitted: (s) => _search(s),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(8),
                    UppercaseToLowercaseTextInputFormatter(),
                  ],
                  style:
                      NeumorphicStyle(boxShape: NeumorphicBoxShape.stadium()),
                  hintText: "search...",
                  textInputAction: TextInputAction.search,
                ),
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
                  ),
                ),
              ),
            ),
            extendBodyBehindAppBar: true,
            body: Center(
              child: AnimatedSwitcher(
                duration: Duration(
                  milliseconds: 500,
                ),
                child: _buildContent(state),
              ),
            ),
            floatingActionButton: NeumorphicFloatingActionButton(
              child: Icon(Ionicons.home_outline),
              onPressed: () => Navigator.pop(context),
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
