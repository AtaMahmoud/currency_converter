import 'package:shared_preferences/shared_preferences.dart';

import '../../business_logic/models/rate.dart';
import './storage_service.dart';

class SharedPreferncesStorage implements StorageService {
  final String timeKey = "time";
  final String rateKey = "rate";

  @override
  Future<Rate?> getExchangeRate() async {
    final prefs = await SharedPreferences.getInstance();
    int? time = prefs.getInt(timeKey);
    if (time == null) return null;

    double? rate = prefs.getDouble(rateKey);

    return Rate(exchangeRate: rate!, fetchTime: time);
  }

  @override
  Future<void> saveExchangeRate(Rate rate) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(rateKey, rate.exchangeRate);
    prefs.setInt(timeKey, rate.fetchTime);
  }
}
