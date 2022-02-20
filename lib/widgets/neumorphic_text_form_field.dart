import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:points/widgets/hider.dart';

import 'neumorphic_text_field.dart';

/// The [NeumorphicTextField] as a [FormField] to be used in forms
class NeumorphicTextFormField extends FormField<String> {
  NeumorphicTextFormField({
    Key? key,
    String? hintText,
    String? errorText,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    AutovalidateMode? autovalidateMode,
    List<TextInputFormatter> inputFormatters = const [],
    TextInputAction? textInputAction,
    bool autofocus = false,
    TextInputType? keyboardType,
    FocusNode? focusNode,
    void Function(String)? onFieldSubmitted,
    void Function(String)? onChanged,
    bool obscureText = false,
  }) : super(
          key: key,
          onSaved: onSaved,
          autovalidateMode: autovalidateMode,
          validator: validator,
          builder: (FormFieldState<String> field) {
            final NeumorphicTextFormFieldState state =
                field as NeumorphicTextFormFieldState;
            late final String? finalErrorText;
            if (field.hasError) {
              finalErrorText = field.errorText;
            } else {
              finalErrorText = errorText;
            }
            return Builder(
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NeumorphicTextField(
                      controller: state._effectiveController,
                      obscureText: obscureText,
                      keyboardType: keyboardType,
                      textInputAction: textInputAction,
                      autocorrect: false,
                      focusNode: focusNode,
                      autofocus: autofocus,
                      hintText: hintText,
                      onSubmitted: onFieldSubmitted,
                      onChanged: (s) {
                        if (onChanged != null) onChanged(s);
                        return state.didChange(s);
                      },
                      inputFormatters: inputFormatters,
                    ),
                    // SizeTransition(sizeFactor: sizeFactor),
                    Hider(
                      hide: finalErrorText == null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          finalErrorText ?? "",
                          style: Theme.of(context).textTheme.caption!.copyWith(
                                color: Theme.of(context).errorColor,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );

  @override
  NeumorphicTextFormFieldState createState() => NeumorphicTextFormFieldState();
}

/// Copied and modified from flutter/lib/src/material/text_form_field.dart (Flutter SDK)
class NeumorphicTextFormFieldState extends FormFieldState<String> {
  TextEditingController? _controller;

  TextEditingController? get _effectiveController => _controller;

  @override
  NeumorphicTextFormField get widget => super.widget as NeumorphicTextFormField;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didChange(String? value) {
    super.didChange(value);

    if (_effectiveController!.text != value)
      _effectiveController!.text = value ?? '';
  }

  @override
  void reset() {
    // setState will be called in the superclass, so even though state is being
    // manipulated, no setState call is needed here.
    _effectiveController!.text = widget.initialValue ?? '';
    super.reset();
  }
}
