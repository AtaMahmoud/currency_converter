import 'package:intl/intl.dart';

class Rate {
  final int fetchTime;
  final double exchangeRate;

  Rate({required this.exchangeRate, required this.fetchTime});

  factory Rate.fromJson(Map<String, dynamic> json) {
    return Rate(exchangeRate: json['rate'], fetchTime: json['time']);
  }

  String get rate => exchangeRate.toStringAsFixed(2);
  String get time {
    final currentFetchTime = DateTime.fromMillisecondsSinceEpoch(fetchTime);
    return DateFormat.yMMMMd().add_jm().format(currentFetchTime);
  }
}
