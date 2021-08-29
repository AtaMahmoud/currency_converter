import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/constants.dart';
import '../../services/dependency_assembler.dart';
import '../../business_logic/view_models/currency_exchange_view_model.dart';
import '../../business_logic/models/currency.dart';
import '../shared/responsive_safe_area.dart';

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
    _currencyExchangeViewModel.initRateState();
    super.initState();
  }

  @override
  void dispose() {
    _currencyExchangeViewModel.dispose();
    baseCurrencyTextEditController.dispose();
    convertedCurrencyTextEditController.dispose();
    super.dispose();
  }

  bool _isLargeScreen(Size size) => size.shortestSide >= 550;
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Currency Converter",
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
                    const SizedBox(height: 20),
                    const Label(text: "Principal Amount"),
                    ValueListenableBuilder<Currency>(
                        valueListenable:
                            _currencyExchangeViewModel.baseCurrency,
                        builder: (context, Currency currency, child) {
                          baseCurrencyTextEditController.text =
                              currency.currentAmount;
                          return CurrencyInputField(
                            currency: currency,
                            controller: baseCurrencyTextEditController,
                            onChange:
                                _currencyExchangeViewModel.baseCurrencyAmount,
                          );
                        }),
                    Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                            onPressed:
                                _currencyExchangeViewModel.swapCurrencies,
                            icon: const Icon(Icons.swap_vert),
                            label: const Text("Switch"))),
                    const Label(text: "Converted Amount"),
                    ValueListenableBuilder<Currency>(
                        valueListenable:
                            _currencyExchangeViewModel.convertedCurrency,
                        builder: (context, Currency currency, child) {
                          convertedCurrencyTextEditController.text =
                              currency.currentAmount;
                          return CurrencyInputField(
                            currency: currency,
                            controller: convertedCurrencyTextEditController,
                            onChange: _currencyExchangeViewModel
                                .convertedCurrencyAmount,
                          );
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    ValueListenableBuilder(
                        valueListenable:
                            _currencyExchangeViewModel.rateNotifier,
                        builder: (context, viewState, child) {
                          if (_currencyExchangeViewModel
                                  .viewStaeNotifier.value ==
                              ViewState.busy) {
                            return const Text("Fetching Exchange Rate...");
                          } else {
                            return BottomText(
                              exchangeRate: _currencyExchangeViewModel
                                  .rateNotifier.value!.rate,
                              lastUpdate: _currencyExchangeViewModel
                                  .rateNotifier.value!.time,
                            );
                          }
                        }),
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

class Label extends StatelessWidget {
  const Label({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(fontWeight: FontWeight.w600));
  }
}

class CurrencyInputField extends StatefulWidget {
  const CurrencyInputField(
      {Key? key,
      required this.currency,
      required this.controller,
      required this.onChange})
      : super(key: key);

  final Currency currency;
  final TextEditingController controller;
  final Function(String) onChange;

  @override
  _CurrencyInputFieldState createState() => _CurrencyInputFieldState();
}

class _CurrencyInputFieldState extends State<CurrencyInputField> {
  final currencyScreenLogic = dependencyAssmbler<CurrencyExchangeViewModel>();

  final _foucsNode = FocusNode();
  @override
  void initState() {
    _foucsNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _foucsNode.removeListener(() {});
    _foucsNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: themeData.inputDecorationTheme.fillColor!,
          border: Border.all(
            color: _foucsNode.hasFocus ? themeData.primaryColor : Colors.grey,
          )),
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: [
          Image.asset(
            widget.currency.iconPath,
            width: 28,
            height: 28,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(widget.currency.isoName),
          const SizedBox(
            width: 8,
          ),
          Expanded(
              child: TextField(
            focusNode: _foucsNode,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.end,
            controller: widget.controller,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"^(\d*\.)?\d+$")),
              LengthLimitingTextInputFormatter(amountFieldsMaxPrecision)
            ],
            onChanged: widget.onChange,
          )),
        ],
      ),
    );
  }
}

class BottomText extends StatelessWidget {
  final String lastUpdate;
  final String exchangeRate;

  const BottomText(
      {Key? key, required this.lastUpdate, required this.exchangeRate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.subtitle2!.copyWith(color: Colors.grey);
    return Center(
      child: Column(
        children: [
          Text(
            "1 BTC = $exchangeRate USD",
            style: textStyle,
          ),
          Text("Last update at $lastUpdate", style: textStyle)
        ],
      ),
    );
  }
}
