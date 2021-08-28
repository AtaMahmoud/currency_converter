import '../../business_logic/models/rate.dart';

abstract class StorageService {
  Future<void> saveExchangeRate(Rate rate);
  Future<Rate?> getExchangeRate();
}
