import '../../business_logic/models/rate.dart';

abstract class CurrencyService {
  Future<Rate> getExchangeRate();
}
