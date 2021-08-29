import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../utils/constants.dart';
import '../../services/dependency_assembler.dart';
import '../../services/currency/currency_service.dart';
import '../../utils/assets_paths.dart';
import '../models/currency.dart';
import '../models/rate.dart';

class CurrencyExchangeViewModel {
  final int _maxBtcAmount = 350;

  final rateNotifier = ValueNotifier<Rate?>(null);
  final failure = ValueNotifier<String>("");
  final viewStaeNotifier = ValueNotifier<ViewState>(ViewState.idle);

  final baseCurrency = ValueNotifier<Currency>(
      Currency(iconPath: usaFlag, isoName: "USD", symbol: "\$"));

  final convertedCurrency = ValueNotifier<Currency>(
      Currency(iconPath: bitcoinLogo, isoName: "BTC", symbol: "₿"));

  void swapCurrencies() {
    final temp = baseCurrency.value;
    baseCurrency.value = convertedCurrency.value;
    convertedCurrency.value = temp;
  }

  void _adjustBtcAmount() {
    double btcAmount = baseCurrency.value.symbol == "BTC"
        ? baseCurrency.value.amount!
        : convertedCurrency.value.amount!;

    if (btcAmount <= _maxBtcAmount) return;

    baseCurrency.value.symbol == "BTC"
        ? baseCurrencyAmount(baseCurrency.value.currentAmount)
        : convertedCurrencyAmount(convertedCurrency.value.currentAmount);
  }

  void baseCurrencyAmount(String value) {
    if (value.isEmpty) {
      _updateConvertedCurrencyAmount(null);
      return;
    }

    double updatedAmount = double.parse(value);

    final newAmount = updatedAmount * baseCurrency.value.exchangeRate!;

    _updateConvertedCurrencyAmount(newAmount);
    //_adjustBtcAmount();
  }

  void _updateConvertedCurrencyAmount(double? newAmount) {
    final updatedCurrency =
        convertedCurrency.value.copyWithNew(amount: newAmount);

    convertedCurrency.value = updatedCurrency;
  }

  void convertedCurrencyAmount(String value) {
    if (value.isEmpty) {
      _updateBaseCurrencyAmount(null);
      return;
    }
    double updatedAmount = double.parse(value);

    final newAmount = updatedAmount * convertedCurrency.value.exchangeRate!;

    _updateBaseCurrencyAmount(newAmount);
   // _adjustBtcAmount();
  }

  void _updateBaseCurrencyAmount(double? newAmount) {
    final updatedCurrency = baseCurrency.value.copyWithNew(amount: newAmount);

    baseCurrency.value = updatedCurrency;
  }

  void _initCurrenciesRates() {
    final exchangeRate = rateNotifier.value!.exchangeRate;
    if (baseCurrency.value.isoName == "BTC") {
      baseCurrency.value.exchangeRate = exchangeRate;
      convertedCurrency.value.exchangeRate = 1 / exchangeRate;
    } else {
      baseCurrency.value.exchangeRate = 1 / exchangeRate;
      convertedCurrency.value.exchangeRate = exchangeRate;
    }
  }

  final _currencyService = dependencyAssmbler<CurrencyService>();
  Timer? _timer;

  Future<void> initRateState() async {
    await _updateExchangeRate();
    _timer = Timer.periodic(const Duration(minutes: fetchPeriodInMinutes),
        (_) => _updateExchangeRate());
  }

  Future<void> _updateExchangeRate() async {
    viewStaeNotifier.value = ViewState.busy;
    rateNotifier.value = await _currencyService.getExchangeRate();
    _initCurrenciesRates();
    viewStaeNotifier.value = ViewState.idle;
  }

  void dispose() {
    _timer!.cancel();
  }
}

enum ViewState { idle, busy }
