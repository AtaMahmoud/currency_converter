import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../utils/constants.dart';
import '../../services/dependency_assembler.dart';
import '../../services/currency/currency_service.dart';
import '../../utils/assets_paths.dart';
import '../models/currency.dart';
import '../models/rate.dart';
import '../models/failure.dart';

class CurrencyExchangeViewModel {
  final int _maxBtcAmount = 350;

  final rateNotifier = ValueNotifier<Rate?>(null);
  final failure = ValueNotifier<Failure?>(null);
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
    baseCurrency.value.amount = updatedAmount;
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
    convertedCurrency.value.amount = updatedAmount;
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
    int? timeLeft = _getCacheLeftTime();

    _timer = Timer.periodic(Duration(minutes: timeLeft ?? fetchPeriodInMinutes),
        (_) async {
      timeLeft = null;
      await _updateExchangeRate();
    });
  }

  /// Get cached rate left time to expire
  /// if [consumedMinutes] equals zero this means it's fresh fetched rate
  int? _getCacheLeftTime() {
    int consumedMinutes = DateTime.now()
        .difference(
            DateTime.fromMillisecondsSinceEpoch(rateNotifier.value!.fetchTime))
        .inMinutes;

    int? timeLeft;
    if (consumedMinutes != 0) timeLeft = fetchPeriodInMinutes - consumedMinutes;
    return timeLeft != null && timeLeft < 0 ? null : timeLeft;
  }

  Future<void> _updateExchangeRate() async {
    viewStaeNotifier.value = ViewState.busy;
    try {
      rateNotifier.value = await _currencyService.getExchangeRate();
      _initCurrenciesRates();
      failure.value = null;
    } catch (e) {
      failure.value = e as Failure;
    }
    viewStaeNotifier.value = ViewState.idle;
  }

  void dispose() {
    _timer!.cancel();
  }
}

enum ViewState { idle, busy }
