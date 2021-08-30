import 'package:flutter/material.dart';

class ExchangeRateWithFetchTime extends StatelessWidget {
  final String lastUpdate;
  final String exchangeRate;

  const ExchangeRateWithFetchTime({
    Key? key,
    required this.lastUpdate,
    required this.exchangeRate,
  }) : super(key: key);

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
          Text("Last update at $lastUpdate", style: textStyle),
        ],
      ),
    );
  }
}
