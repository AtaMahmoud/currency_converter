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
  final double _maxBtcAmount = 500;

  final rateNotifier = ValueNotifier<Rate?>(null);
  final failure = ValueNotifier<Failure?>(null);
  final viewStaeNotifier = ValueNotifier<ViewState>(ViewState.idle);

  final baseCurrency = ValueNotifier<Currency>(
      Currency(iconPath: usaFlag, isoName: "USD", symbol: "\$"));

  final convertedCurrency = ValueNotifier<Currency>(
      Currency(iconPath: bitcoinLogo, isoName: "BTC", symbol: "B"));

  void swapCurrencies() {
    final temp = baseCurrency.value;
    baseCurrency.value = convertedCurrency.value;
    convertedCurrency.value = temp;
  }

  bool isTextFieldsEnabled() =>
      viewStaeNotifier.value != ViewState.busy &&
      (failure.value == null || rateNotifier.value != null);

  bool _isBtcAmountExceedMaxBtcAmount() {
    double btcAmount = baseCurrency.value.isoName == "BTC"
        ? baseCurrency.value.amount!
        : convertedCurrency.value.amount!;

    return btcAmount <= _maxBtcAmount;
  }

  void _adjustBtcAmount() {
    if (_isBtcAmountExceedMaxBtcAmount()) return;

    double usdAmount = rateNotifier.value!.exchangeRate * _maxBtcAmount;

    if (baseCurrency.value.isoName == "BTC") {
      _updateCurrencyAmount(baseCurrency, _maxBtcAmount);
      _updateCurrencyAmount(convertedCurrency, usdAmount);
    } else {
      _updateCurrencyAmount(baseCurrency, usdAmount);
      _updateCurrencyAmount(convertedCurrency, _maxBtcAmount);
    }

    _notifiyCurrencyListner(baseCurrency);
    _notifiyCurrencyListner(convertedCurrency);
  }

  void _notifiyCurrencyListner(ValueNotifier<Currency> currency) {
    final currencyValue = currency.value;
    currency.value = currencyValue.copyWithNew(amount: currencyValue.amount);
  }

  void updateBaseCurrencyAmount(String value) {
    if (value.isEmpty) {
      _updateCurrencyAmount(convertedCurrency, null);
      _updateCurrencyAmount(baseCurrency, null);
      return;
    }

    final newAmount =
        _exchangeCurrency(baseCurrency, _getAbsoluteAmount(value));

    _updateCurrencyAmount(convertedCurrency, newAmount);
    _adjustBtcAmount();
  }

  double _exchangeCurrency(ValueNotifier<Currency> currency, String amount) {
    double updatedAmount = double.parse(amount);
    currency.value.amount = updatedAmount;
    return updatedAmount * currency.value.exchangeRate!;
  }

  void _updateCurrencyAmount(ValueNotifier currency, double? newAmount) =>
      currency.value = currency.value.copyWithNew(amount: newAmount);

  void updateConvertedCurrencyAmount(String value) {
    if (value.isEmpty) {
      _updateCurrencyAmount(baseCurrency, null);
      _updateCurrencyAmount(convertedCurrency, null);
      return;
    }

    final newAmount =
        _exchangeCurrency(convertedCurrency, _getAbsoluteAmount(value));

    _updateCurrencyAmount(baseCurrency, newAmount);
    _adjustBtcAmount();
  }

  String _getAbsoluteAmount(String value) =>
      value.substring(1).replaceAll(",", "");

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

  Future<void> fetchExchangeRate() async {
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
    if (rateNotifier.value == null) return null;

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
