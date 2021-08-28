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
    return amount.toString();
  }
}
