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

  String get currentAmount {
    if (amount == null) return "";

    if (amount! < 1 && isoName == "BTC") return amount!.toStringAsFixed(8);

    return amount!.toStringAsFixed(2);
  }

  String _formateAmount(double amount, int decimalDigits) =>
      NumberFormat.currency(symbol: symbol, decimalDigits: decimalDigits)
          .format(amount);

  Currency copyWithNew({double? amount}) {
    return Currency(
        iconPath: iconPath,
        isoName: isoName,
        symbol: symbol,
        exchangeRate: exchangeRate,
        amount: amount);
  }
}
