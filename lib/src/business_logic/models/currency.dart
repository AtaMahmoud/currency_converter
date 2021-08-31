import 'package:intl/intl.dart';

class Currency {
  final String symbol;
  final String isoName;
  final String iconPath;
  late double? exchangeRate;
  late double? amount;

  Currency(
      {required this.iconPath,
      required this.isoName,
      this.exchangeRate,
      this.amount,
      required this.symbol});

  set currencyAmount(double amount) => amount = amount;
  set rate(double rate) => exchangeRate = rate;

  String get formattedAmount {
    if (amount == null) return "";

    if (amount! < 1) return _formateAmount(amount!, 8);

    return _formateAmount(amount!, 2);
  }

  String _formateAmount(double amount, int decimalDigit) =>
      NumberFormat.currency(symbol: symbol, decimalDigits: decimalDigit).format(
        amount,
      );

  Currency copyWithNew({double? amount}) {
    return Currency(
        iconPath: iconPath,
        isoName: isoName,
        symbol: symbol,
        exchangeRate: exchangeRate,
        amount: amount);
  }
}
