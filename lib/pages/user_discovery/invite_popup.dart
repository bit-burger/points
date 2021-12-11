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

class InvitePopup extends StatelessWidget {
  Widget _buildTextField(BuildContext context) {
    return BlocBuilder<EmailUserInviterCubit, EmailUserInviterState>(
      buildWhen: (oldState, newState) {
        return newState is! EmailUserInviterLoading;
      },
      builder: (context, state) {
        String? error;
        if (state is EmailUserInviterError) {
          error = state.message;
        }
        return NeumorphicTextFormField(
          errorText: error,
          hintText: "email",
          onFieldSubmitted:
              state is! EmailUserInviterFound ? null : (s) => _submit(context),
          onChanged: (s) {
            context
                .read<EmailUserInviterCubit>()
                .updateSearchQuery(searchQuery: s);
          },
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
      builder: (context, state) {
        final loading = state is EmailUserInviterRequestLoading;
        final disabled = state is EmailUserInviterError ||
            state is EmailUserInviterLoading ||
            state is EmailUserInviterInitial;
        return Center(
          child: NeumorphicLoadingTextButton(
            onPressed: disabled ? null : () => _submit(context),
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
      child: Neumorphic(
        child: Column(
          children: [
            BlocBuilder<EmailUserInviterCubit, EmailUserInviterState>(
              buildWhen: (oldState, newState) {
                return newState is EmailUserInviterFinished ||
                    newState is EmailUserInviterInitial;
              },
              builder: (context, state) {
                late final Widget widget;
                if (state is EmailUserInviterFinished) {
                  widget = Column(
                    key: ValueKey("initial"),
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 32),
                      RichText(
                        text: TextSpan(
                          style:
                              Theme.of(context).textTheme.headline6!.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                          children: [
                            WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.check,
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                            ),
                            TextSpan(text: "user successfully added"),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: NeumorphicLoadingTextButton(
                          onPressed: () {
                            context.read<EmailUserInviterCubit>().reset();
                          },
                          child: Text("Add another user"),
                        ),
                      ),
                    ],
                  );
                } else {
                  widget = Column(
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildTextField(context),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _buildButton(context),
                      ),
                    ],
                  );
                }
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: widget,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    context.read<EmailUserInviterCubit>().requestUser();
  }
}
