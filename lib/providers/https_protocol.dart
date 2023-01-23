import 'dart:convert';

import 'package:cbesdesktop/private_data.dart';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

class HttpProtocol {
  static Future<List> querySolarHeater(
      {required String fromDate, required String toDate}) async {
    final solarHeaterResponse =

    await http.get(
      Uri.parse('http://34.219.126.46/cbes/tank_temp'),
      headers: {"fromDate": fromDate, "toDate": toDate});

    // await http.get(Uri.parse('$firebaseDbUrl/cbes_data/temperature.json'));
    print(solarHeaterResponse);
    final solarHeaterData =  solarHeaterResponse.body as List;

    print(solarHeaterData);
    return solarHeaterData;
  }
}
