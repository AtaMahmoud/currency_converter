import 'dart:math';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final String symbol;
  CurrencyInputFormatter({
    required this.symbol,
  });

  String _formate(String newText) {
    final NumberFormat format = NumberFormat.currency(
      symbol: symbol,
    );

    num parsedNumber = num.tryParse(newText) ?? 0;
    if (format.decimalDigits! > 0) {
      parsedNumber /= pow(10, format.decimalDigits!);
    }
    return format.format(parsedNumber).trim();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    if (newText.trim().isEmpty || newText == '0'||newText == '00') {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final formattedAmount = _formate(newText);

    return TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }
}
