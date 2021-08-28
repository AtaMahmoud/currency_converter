import 'package:get_it/get_it.dart';

import '../business_logic/view_models/currency_exchange_view_model.dart';
import './storage/storage_service.dart';
import './storage/shared_prefernces_storage.dart';
import './web_api/coingecko_web_api.dart';
import './web_api/web_api.dart';
import './currency/currency_service.dart';
import './currency/currency_service_implementation.dart';

GetIt dependencyAssmbler = GetIt.instance;

void setupDependencyAssembler() {
  dependencyAssmbler.registerFactory<WebApi>(() => CoingeckoWebApi());
  dependencyAssmbler
      .registerFactory<StorageService>(() => SharedPreferncesStorage());
  dependencyAssmbler
      .registerFactory<CurrencyService>(() => CurrencyServiceImplementation());
  dependencyAssmbler.registerFactory<CurrencyExchangeViewModel>(
      () => CurrencyExchangeViewModel());
}
