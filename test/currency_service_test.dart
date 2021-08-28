import 'package:currency_converter/src/business_logic/models/rate.dart';
import 'package:currency_converter/src/services/currency/currency_service.dart';
import 'package:currency_converter/src/services/currency/currency_service_implementation.dart';
import 'package:currency_converter/src/services/dependency_assembler.dart';
import 'package:currency_converter/src/services/storage/storage_service.dart';
import 'package:currency_converter/src/services/web_api/web_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'currency_service_test.mocks.dart';

@GenerateMocks([StorageService, WebApi])
void main() {
  late Rate validFakeRate;
  late Rate inValidFakeRate;

  setUpAll(() {
    setupDependencyAssembler();
    dependencyAssmbler.allowReassignment = true;

    validFakeRate = Rate(
        exchangeRate: 49250,
        fetchTime: DateTime.now()
            .subtract(const Duration(minutes: 5))
            .millisecondsSinceEpoch);
    inValidFakeRate = Rate(
        exchangeRate: 49250,
        fetchTime: DateTime.now()
            .subtract(const Duration(minutes: 20))
            .millisecondsSinceEpoch);
  });
  late MockStorageService _mockStorage;
  late MockWebApi _mockWebApi;
  setUp(() {
    _mockStorage = MockStorageService();
    _mockWebApi=MockWebApi();
  });

  test("Constructing Service should find correct dependencies", () {
    final _crruencyService = dependencyAssmbler<CurrencyService>();
    expect(_crruencyService, isNotNull);
  });

  test("should return cached rate if it valid", () async {
    when(_mockStorage.getExchangeRate())
        .thenAnswer((_) => Future.value(validFakeRate));
    dependencyAssmbler.registerFactory<StorageService>(() => _mockStorage);
    dependencyAssmbler.registerFactory<WebApi>(() => _mockWebApi);

    final _crruencyService = CurrencyServiceImplementation();
    final rate = await _crruencyService.getExchangeRate();

    expect(rate.exchangeRate, equals(validFakeRate.exchangeRate));
  });

  test("should return rate from web api if cache not found", () async {
    when(_mockStorage.getExchangeRate())
        .thenAnswer((_) async => Future.value(null));
    when(_mockStorage.saveExchangeRate(validFakeRate))
        .thenAnswer((_) => Future.value());
    when(_mockWebApi.fetchExchangeRate())
        .thenAnswer((_) async => Future.value(validFakeRate));
    dependencyAssmbler.registerFactory<StorageService>(() => _mockStorage);

    final _crruencyService = CurrencyServiceImplementation();
    final rate = await _crruencyService.getExchangeRate();

    expect(rate, isNotNull);
  });

  test("should return rate from web api if cache expired", () async {
    when(_mockStorage.getExchangeRate())
        .thenAnswer((_) async => Future.value(inValidFakeRate));
    when(_mockStorage.saveExchangeRate(validFakeRate))
        .thenAnswer((_) => Future.value());
    when(_mockWebApi.fetchExchangeRate())
        .thenAnswer((_) async => Future.value(validFakeRate));
    dependencyAssmbler.registerFactory<StorageService>(() => _mockStorage);
    dependencyAssmbler.registerFactory<WebApi>(() => _mockWebApi);

    final _crruencyService = CurrencyServiceImplementation();
    final rate = await _crruencyService.getExchangeRate();

    expect(rate, isNotNull);
    expect(rate.fetchTime, equals(validFakeRate.fetchTime));
  });

  test(
      "should throw exception if the cache not found and web api throw exception",
      () async {
    when(_mockStorage.getExchangeRate())
        .thenAnswer((_) async => Future.value(null));
    when(_mockWebApi.fetchExchangeRate())
        .thenThrow(Exception("Something went wrong"));
    dependencyAssmbler.registerFactory<StorageService>(() => _mockStorage);
    dependencyAssmbler.registerFactory<WebApi>(() => _mockWebApi);

    final _crruencyService = CurrencyServiceImplementation();

    expect(
        () async => await _crruencyService.getExchangeRate(), throwsException);
  });

  test(
      "should return invalid cached Rate if web api throws an exception",
      () async {
    when(_mockStorage.getExchangeRate())
        .thenAnswer((_) async => Future.value(inValidFakeRate));

    when(_mockWebApi.fetchExchangeRate())
        .thenThrow(Exception("Something went wrong"));
    dependencyAssmbler.registerFactory<StorageService>(() => _mockStorage);
    dependencyAssmbler.registerFactory<WebApi>(() => _mockWebApi);

    final _crruencyService = CurrencyServiceImplementation();
    final rate = await _crruencyService.getExchangeRate();
    expect(rate.exchangeRate, equals(inValidFakeRate.exchangeRate));
  });
}
