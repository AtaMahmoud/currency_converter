import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../business_logic/models/failure.dart';
import '../../../business_logic/models/rate.dart';
import '../../../services/dependency_assembler.dart';
import '../../../business_logic/view_models/currency_exchange_view_model.dart';
import '../../../business_logic/models/currency.dart';
import '../../shared/responsive_safe_area.dart';
import '../../shared/value_listenable_builder.dart';
import './widgets/failure_label.dart';
import './widgets/label.dart';
import './widgets/currency_text_field.dart';
import './widgets/exchange_rate_with_fetch_time.dart';

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({Key? key}) : super(key: key);

  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final _currencyExchangeViewModel =
      dependencyAssmbler<CurrencyExchangeViewModel>();
  final baseCurrencyTextEditController = TextEditingController();
  final convertedCurrencyTextEditController = TextEditingController();
  @override
  void initState() {
    _currencyExchangeViewModel.fetchExchangeRate();
    _clearAnotherTextField(
        baseCurrencyTextEditController, convertedCurrencyTextEditController);

    _clearAnotherTextField(
        convertedCurrencyTextEditController, baseCurrencyTextEditController);

    super.initState();
  }

  void _clearAnotherTextField(TextEditingController baseController,
      TextEditingController convertedController) {
    baseController.addListener(() {
      if (baseController.text.isEmpty && convertedController.text.isNotEmpty) {
        convertedController.clear();
      }
    });
  }

  @override
  void dispose() {
    _currencyExchangeViewModel.dispose();

    baseCurrencyTextEditController.removeListener(() {});
    baseCurrencyTextEditController.dispose();

    convertedCurrencyTextEditController.removeListener(() {});
    convertedCurrencyTextEditController.dispose();

    super.dispose();
  }

  Widget _buildBaseCurrencyInputField() {
    final appLocalizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Label(text: appLocalizations.baseAmount),
        const SizedBox(height: 6),
        ValueListenableBuilder2<Currency, ViewState>(
          _currencyExchangeViewModel.baseCurrency,
          _currencyExchangeViewModel.viewStaeNotifier,
          builder: (context, currency, viewState, child) {
            _setTextEditControllerValue(
                currency, baseCurrencyTextEditController);
            return CurrencyInputField(
              key: ValueKey(currency.isoName),
              currency: currency,
              isEnabled: _currencyExchangeViewModel.isTextFieldsEnabled(),
              controller: baseCurrencyTextEditController,
              onChange: _currencyExchangeViewModel.updateBaseCurrencyAmount,
            );
          },
        ),
      ],
    );
  }

  Widget _builConvertedCurrencyInputField() {
    final appLocalizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Label(text: appLocalizations.convertedAmount),
        const SizedBox(height: 6),
        ValueListenableBuilder2<Currency, ViewState>(
          _currencyExchangeViewModel.convertedCurrency,
          _currencyExchangeViewModel.viewStaeNotifier,
          builder: (context, currency, viewState, child) {
            _setTextEditControllerValue(
                currency, convertedCurrencyTextEditController);
            return CurrencyInputField(
              key: ValueKey(currency.isoName),
              currency: currency,
              isEnabled: _currencyExchangeViewModel.isTextFieldsEnabled(),
              controller: convertedCurrencyTextEditController,
              onChange:
                  _currencyExchangeViewModel.updateConvertedCurrencyAmount,
            );
          },
        )
      ],
    );
  }

  void _setTextEditControllerValue(
      Currency currency, TextEditingController controller) {
    if (_currencyExchangeViewModel.isTextFieldsEnabled() && currency.amount != null) {
      final formattedAmount = currency.formattedAmount;
      controller.value = TextEditingValue(
          text: formattedAmount,
          selection: TextSelection.collapsed(offset: formattedAmount.length));
    }
  }

  Widget _buildBottomSection() {
    return ValueListenableBuilder2<Rate?, Failure?>(
      _currencyExchangeViewModel.rateNotifier,
      _currencyExchangeViewModel.failure,
      builder: (context, rate, failure, child) {
        if (_currencyExchangeViewModel.viewStaeNotifier.value ==
            ViewState.busy) {
          return Text("${AppLocalizations.of(context)!.fetchExchangeRate}...");
        } else {
          if (failure != null && rate == null) {
            return FailureLabel(failure: failure);
          }

          return ExchangeRateWithFetchTime(
            exchangeRate: _currencyExchangeViewModel.rateNotifier.value!.rate,
            lastUpdate: _currencyExchangeViewModel.rateNotifier.value!.time,
          );
        }
      },
    );
  }

  bool _isLargeScreen(Size size) => size.shortestSide >= 550;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          appLocalizations.title,
          style: themeData.textTheme.headline6!.copyWith(color: Colors.white),
        ),
      ),
      body: ResponsiveSafeArea(builder: (context, size) {
        return GestureDetector(
          onTap: FocusManager.instance.primaryFocus?.unfocus,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.topCenter,
              width: _isLargeScreen(size) ? size.width * .5 : size.width * .95,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildBaseCurrencyInputField(),
                    const SizedBox(height: 6),
                    Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                            onPressed:
                                _currencyExchangeViewModel.swapCurrencies,
                            icon: const Icon(Icons.swap_vert),
                            label: Text(appLocalizations.switchAmounts))),
                    _builConvertedCurrencyInputField(),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: _buildBottomSection(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
