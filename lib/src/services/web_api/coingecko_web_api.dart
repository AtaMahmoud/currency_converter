import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../business_logic/models/rate.dart';
import './web_api.dart';

class CoingeckoWebApi implements WebApi {
  final _host = 'api.coingecko.com';
  final _unencodedPath = "api/v3/exchange_rates";
  final Map<String, String> _headers = {'accept': 'application/json'};

  @override
  Future<Rate> fetchExchangeRate() async {
    final uri = Uri.https(_host, _unencodedPath);
    final result = await http.get(uri, headers: _headers);

    if (result.statusCode != 200) throw Exception("Something went worng!");

    final decodedResult = json.decode(result.body);
    return Rate.fromJson({
      'rate': decodedResult['rates']['usd']['value'],
      'time': DateTime.now().millisecondsSinceEpoch
    });
  }
}
