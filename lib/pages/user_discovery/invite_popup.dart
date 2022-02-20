import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:points/helpers/uppercase_to_lowercase_text_input_formatter.dart';
import 'package:points/state_management/auth/auth_cubit.dart';
import 'package:points/state_management/user_discovery/email_user_inviter_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:points/widgets/loader.dart';
import 'package:points/widgets/neumorphic_loading_text_button.dart';
import 'package:points/widgets/neumorphic_text_form_field.dart';
import 'package:user_repositories/relations_repository.dart';
import 'package:user_repositories/user_discovery_repository.dart';
import '../../helpers/reg_exp.dart' as regExp;

/// Invite by email, using the [EmailUserInviterCubit]
/// to validate the email/if it belongs to somebody.
class InvitePopup extends StatefulWidget {
  @override
  State<InvitePopup> createState() => _InvitePopupState();
}

class _InvitePopupState extends State<InvitePopup> {
  String email = "";
  final FocusNode _focusNode = FocusNode(skipTraversal: true);

  Widget _buildTextField(BuildContext context) {
    return BlocBuilder<EmailUserInviterCubit, EmailUserInviterState>(
      buildWhen: (oldState, newState) {
        return newState is! EmailUserInviterRequestLoading;
      },
      builder: (context, state) {
        String? error;
        if (state is EmailUserInviterError) {
          error = state.message;
        }
        return NeumorphicTextFormField(
          errorText: error,
          textInputAction: TextInputAction.send,
          focusNode: _focusNode,
          autofocus: true,
          hintText: "email",
          onFieldSubmitted: (email) {
            context.read<EmailUserInviterCubit>().requestUser(email);
            Future.microtask(() => _focusNode.requestFocus());
          },
          onChanged: (s) => email = s,
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [
            FilteringTextInputFormatter(
              regExp.emailFilter,
              allow: true,
            ),
            UppercaseToLowercaseTextInputFormatter(),
          ],
        );
      },
    );
  }

  Widget _buildButton(BuildContext context) {
    return BlocBuilder<EmailUserInviterCubit, EmailUserInviterState>(
      buildWhen: (oldState, newState) =>
          oldState is EmailUserInviterRequestLoading !=
          newState is EmailUserInviterRequestLoading,
      builder: (context, state) {
        final loading = state is EmailUserInviterRequestLoading;
        return Center(
          child: NeumorphicLoadingTextButton(
            onPressed: () =>
                context.read<EmailUserInviterCubit>().requestUser(email),
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 56,
              child: Center(child: Text("Request")),
            ),
            loader: SizedBox(
              height: 56,
              child: Loader(),
            ),
            loading: loading,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmailUserInviterCubit>(
      create: (context) {
        return EmailUserInviterCubit(
          authCubit: context.read<AuthCubit>(),
          userDiscoveryRepository: context.read<UserDiscoveryRepository>(),
          relationsRepository: context.read<RelationsRepository>(),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // make sure, that it is over the keyboard
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.transparent),
              ),
            ),
            Neumorphic(
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
              child: Column(
                children: [
                  BlocConsumer<EmailUserInviterCubit, EmailUserInviterState>(
                    buildWhen: (oldState, newState) {
                      return newState is EmailUserInviterInitial;
                    },
                    listener: (context, state) {
                      if (state is EmailUserInviterFinished) {
                        // leave page, when invited successfully
                        Navigator.pop(context);
                      }
                    },
                    builder: (context, state) {
                      return AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child: Column(
                          key: ValueKey("form"),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 24),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Add friend by email",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            SizedBox(
                              height: 90,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: _buildTextField(context),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: _buildButton(context),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
