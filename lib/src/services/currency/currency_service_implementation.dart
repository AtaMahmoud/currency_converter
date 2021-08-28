import '../../utils/constants.dart';
import '../../business_logic/models/rate.dart';
import './currency_service.dart';
import '../dependency_assembler.dart';
import '../storage/storage_service.dart';
import '../web_api/web_api.dart';

class CurrencyServiceImplementation implements CurrencyService {
  final _storageService = dependencyAssmbler<StorageService>();
  final _webApiService = dependencyAssmbler<WebApi>();

  @override
  Future<Rate> getExchangeRate() async {
    bool isValidCache = await _isValidCachedRate();

    final cachedRate = await _storageService.getExchangeRate();
    if (isValidCache) {
      return cachedRate!;
    }

    try {
      final rate = await _webApiService.fetchExchangeRate();
      _storageService.saveExchangeRate(rate);
      return rate;
    } catch (e) {
      if (cachedRate == null) rethrow;
      return cachedRate;
    }
  }

  Future<bool> _isValidCachedRate() async {
    final rate = await _storageService.getExchangeRate();

    if (rate == null) return false;

    final rateFetchTime = DateTime.fromMillisecondsSinceEpoch(rate.fetchTime);
    Duration difference = DateTime.now().difference(rateFetchTime);

    return difference.inMinutes < fetchPeriodInMinutes;
  }
}
