import 'package:flutter/services.dart';

class UppercaseToLowercaseTextInputFormatter implements TextInputFormatter {
  final int maxLength;

  UppercaseToLowercaseTextInputFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.substring(0, maxLength),
      selection: newValue.selection,
    );
  }
}
