import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../business_logic/models/currency.dart';
import '../../../../services/dependency_assembler.dart';
import '../../../../business_logic/view_models/currency_exchange_view_model.dart';
import '../../../../utils/constants.dart';

class CurrencyInputField extends StatefulWidget {
  const CurrencyInputField(
      {Key? key,
      required this.currency,
      required this.controller,
      required this.onChange,
      required this.isEnabled})
      : super(key: key);

  final Currency currency;
  final TextEditingController controller;
  final Function(String) onChange;
  final bool isEnabled;

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
            enabled: widget.isEnabled,
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