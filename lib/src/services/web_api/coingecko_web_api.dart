import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../business_logic/models/failure.dart';
import '../../business_logic/models/rate.dart';
import './web_api.dart';

class CoingeckoWebApi implements WebApi {
  final _host = 'api.coingecko.com';
  final _unencodedPath = "api/v3/exchange_rates";
  final Map<String, String> _headers = {'accept': 'application/json'};

  @override
  Future<Rate> fetchExchangeRate() async {
    try {
      final uri = Uri.https(_host, _unencodedPath);
      final result = await http.get(uri, headers: _headers);

      if (result.statusCode != 200) {
        return Future.error(
          Failure(errorMessage: "Error while fetching."),
          StackTrace.fromString(result.body),
        );
      }

      final decodedResult = json.decode(result.body);
      return Rate.fromJson({
        'rate': decodedResult['rates']['usd']['value'],
        'time': DateTime.now().millisecondsSinceEpoch
      });
    } on SocketException {
      return Future.error(Failure(
          errorMessage: 'No Internet connection 😑', isNoInternet: true));
    } on FormatException {
      return Future.error(Failure(errorMessage: 'Bad response format 👎'));
    } on Exception {
      return Future.error(Failure(errorMessage: 'Unexpected error 😢'));
    }
  }
}
