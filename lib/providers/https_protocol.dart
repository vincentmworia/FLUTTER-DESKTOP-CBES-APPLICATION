import 'dart:convert';

import 'package:cbesdesktop/private_data.dart';
import 'package:http/http.dart' as http;

class HttpProtocol {
  static Future<List> querySolarHeater(
      {required String fromDate, required String toDate}) async {
    final solarHeaterResponse =
        await http.get(Uri.parse('$firebaseDbUrl/cbes_data/temperature.json'));

    // todo Jose API to be in the right format with the right headers
    // await http.get(
    //   Uri.parse('http://34.219.126.46/cbes/tank_temp'),
    //   headers: {"fromDate": fromDate, "toDate": toDate});
    print(solarHeaterResponse);
    final solarHeaterData = json.decode(solarHeaterResponse.body) as List;

    print(solarHeaterData);
    return solarHeaterData;
  }
}
