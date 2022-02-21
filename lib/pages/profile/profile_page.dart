import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide NeumorphicAppBar;
import 'package:points/helpers/uppercase_to_lowercase_text_input_formatter.dart';
import 'package:points/pages/profile/icon_picker_page.dart';
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:points/state_management/profile/profile_cubit.dart';
import 'package:points/state_management/profile/profile_form_bloc.dart';
import 'package:points/widgets/neumorphic_loading_text_button.dart';
import 'package:points/widgets/user_list_tile.dart';
import '../../widgets/neumorphic_app_bar_fix.dart';
import 'package:ionicons/ionicons.dart';
import 'package:points/theme/points_icons.dart';
import 'package:points/widgets/neumorphic_scaffold.dart';
import 'package:user_repositories/profile_repository.dart';
import '../../theme/points_colors.dart' as pointsColors;

/// Change and preview profile with the [ProfileFormBloc]
class ProfilePage extends StatefulWidget {
  static const _textFieldBorder =
      UnderlineInputBorder(borderSide: BorderSide(width: 2));
  static const _textFieldErrorBorder = UnderlineInputBorder(
    borderSide: BorderSide(
      color: pointsColors.errorColor,
      width: 2,
    ),
  );
  static const _textFieldDecoration = InputDecoration(
    isCollapsed: true,
    border: _textFieldBorder,
    disabledBorder: _textFieldBorder,
    enabledBorder: _textFieldBorder,
    focusedBorder: _textFieldBorder,
    errorBorder: _textFieldErrorBorder,
    focusedErrorBorder: _textFieldErrorBorder,
    errorMaxLines: 2,
    contentPadding: EdgeInsets.only(bottom: 6),
    helperText: "",
  );

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isOnIconPage = false;

  Widget _buildIcon(ProfileFormBloc formBloc) {
    return BlocBuilder<ProfileFormBloc, FormBlocState>(
      bloc: formBloc,
      builder: (context, state) {
        return FractionallySizedBox(
          widthFactor: 1 / 2,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Neumorphic(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: GestureDetector(
                      onTapDown: (details) async {
                        setState(() {
                          isOnIconPage = true;
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          isOnIconPage = false;
                        });
                      },
                      onTapUp: (details) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return BlocProvider.value(
                                value: formBloc.iconSelection,
                                child: IconPickerPage(),
                              );
                            },
                          ),
                        );
                        setState(() {
                          isOnIconPage = false;
                        });
                      },
                      child: NeumorphicIcon(
                        pointsIcons[formBloc.iconSelection.value],
                        size: constraints.maxWidth * (17 / 24),
                        curve: Curves.easeOut,
                        style: NeumorphicStyle(
                          color: pointsColors
                              .colors[formBloc.colorSelection.value ?? 0],
                          disableDepth: isOnIconPage,
                        ),
                      ),
                    ),
                  );
                },
              ),
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.circle(),
                depth: -NeumorphicTheme.depth(context)!,
              ),
            ),
          ),
        );
      },
    );
  }

  Iterable<Widget> _buildTextFields(ProfileFormBloc formBloc) sync* {
    yield TextFieldBlocBuilder(
      textFieldBloc: formBloc.nameText,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      inputFormatters: [
        UppercaseToLowercaseTextInputFormatter(),
      ],
      padding: EdgeInsets.only(top: 16),
      decoration: ProfilePage._textFieldDecoration.copyWith(hintText: "name"),
    );

    yield TextFieldBlocBuilder(
      textFieldBloc: formBloc.statusText,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      padding: EdgeInsets.only(top: 16),
      decoration: ProfilePage._textFieldDecoration.copyWith(hintText: "status"),
    );

    yield TextFieldBlocBuilder(
      textFieldBloc: formBloc.bioText,
      keyboardType: TextInputType.multiline,
      autocorrect: false,
      maxLines: null,
      maxLength: null,
      padding: EdgeInsets.only(top: 16),
      decoration: ProfilePage._textFieldDecoration.copyWith(hintText: "bio"),
    );
  }

  Widget _buildSubmitButtons(ProfileFormBloc formBloc) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        return BlocBuilder<ProfileFormBloc, FormBlocState<String, String>>(
          builder: (__, formState) {
            final loading =
                formState is FormBlocLoading || formState is FormBlocSubmitting;
            final disabled = !formState.isValid();
            final hasChanges = formBloc.hasChanges();
            return Row(
              children: [
                Expanded(
                  child: NeumorphicLoadingTextButton(
                    margin: EdgeInsets.only(left: 20),
                    child: Center(child: Text("Submit")),
                    onPressed: disabled || !hasChanges
                        ? null
                        : () => formBloc.submit(),
                    loading: loading,
                    textStyle: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: NeumorphicLoadingTextButton(
                    margin: EdgeInsets.only(right: 20),
                    child: Center(child: Text("Cancel")),
                    onPressed: !hasChanges ? null : () => formBloc.reload(),
                    loading: loading,
                    textStyle: Theme.of(context).textTheme.subtitle1,
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildColorButton(int color, ProfileFormBloc formBloc) {
    final pressed = formBloc.colorSelection.value == color;
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: IgnorePointer(
          ignoring: pressed,
          child: NeumorphicButton(
            child: SizedBox.expand(),
            onPressed: pressed
                ? () {}
                : () {
                    formBloc.colorSelection.updateValue(color);
                  },
            margin: EdgeInsets.all(8),
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
              color: pointsColors.colors[color],
              intensity: 0.8,
              depth: pressed ? -NeumorphicTheme.depth(context)! : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorButtonRows(ProfileFormBloc formBloc) {
    return BlocBuilder<ProfileFormBloc, FormBlocState>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              children: List.generate(
                  5, (index) => _buildColorButton(index, formBloc)),
            ),
            Row(
              children: List.generate(
                  5, (index) => _buildColorButton(index + 5, formBloc)),
            ),
          ],
        );
      },
    );
  }

  // TODO: Preview should be directly under the icon inside the NeumorphicBox
  Widget _buildPreviewUserListTile(ProfileFormBloc formBloc) {
    return IgnorePointer(
      ignoring: true,
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (_, state) {
          return BlocBuilder<ProfileFormBloc, FormBlocState<String, String>>(
            builder: (__, ___) {
              var name = (formBloc.nameText.value).padRight(1);
              var status = (formBloc.statusText.value).padRight(1);
              name = name.substring(0, name.length.clamp(0, 8));
              status = status.substring(0, status.length.clamp(0, 16));
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: UserListTile(
                  key: ValueKey(
                    Object.hash(
                      name,
                      status,
                      formBloc.colorSelection.value,
                      formBloc.iconSelection.value,
                    ),
                  ),
                  onPressed: () {},
                  name: name,
                  status: status,
                  color: formBloc.colorSelection.value ?? 9,
                  points:
                      state is ProfileExistsState ? state.profile.points : 0,
                  icon: formBloc.iconSelection.value,
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileFormBloc(
        authCubit: context.read<AuthCubit>(),
        profileRepository: context.read<ProfileRepository>(),
      ),
      child: Builder(
        builder: (context) {
          final formBloc = context.read<ProfileFormBloc>();
          return NeumorphicScaffold(
            appBar: NeumorphicAppBar(
              title: Text("Profile"),
              leading: NeumorphicBackButton(
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.circle(),
                ),
              ),
              trailing: NeumorphicButton(
                tooltip: "Log out",
                child: Icon(Ionicons.log_out_outline),
                onPressed: () {
                  context.read<AuthCubit>().logOut();
                },
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.circle(),
                ),
              ),
            ),
            body: WillPopScope(
              onWillPop: () async {
                if (!formBloc.hasChanges()) {
                  return true;
                }
                final result = await showOkCancelAlertDialog(
                  title: "Warning",
                  message: "You have unsaved changes, "
                      "do you want to throw them away?",
                  context: context,
                );
                return result == OkCancelResult.ok;
              },
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Neumorphic(
                        margin: EdgeInsets.all(20),
                        style: NeumorphicStyle(
                          depth: -NeumorphicTheme.depth(context)!,
                        ),
                        child: ListView(
                          children: [
                            SizedBox(height: 24),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  _buildIcon(formBloc),
                                  SizedBox(height: 16),
                                  ..._buildTextFields(formBloc),
                                  SizedBox(height: 16),
                                  _buildColorButtonRows(formBloc),
                                ],
                              ),
                            ),
                            SizedBox(height: 24),
                            _buildSubmitButtons(formBloc),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    _buildPreviewUserListTile(formBloc),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
