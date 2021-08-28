import '../../business_logic/models/rate.dart';

abstract class WebApi {
  Future<Rate> fetchExchangeRate();
}
