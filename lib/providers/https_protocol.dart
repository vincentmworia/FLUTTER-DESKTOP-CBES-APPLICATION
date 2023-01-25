import 'dart:convert';

import 'package:cbesdesktop/private_data.dart';
import 'package:http/http.dart' as http;

class HttpProtocol {
  // Temperatures
  static const tank1 = 'Tank1';
  static const tank2 = 'Tank2';
  static const tank3 = 'Tank3';

  static Future<List> querySolarHeater(
      {required String fromDate, required String toDate}) async {
    final solarHeaterResponse =
        await http.get(Uri.parse('$firebaseDbUrl/cbes_data/temperature.json'));
    // todo Jose API to be in the right format with the right headers
    // todo joseph URL is => http://34.219.126.46
    // await http.get(
    //   Uri.parse('$josephDbUrl/cbes/tank_temp'),
    //   headers: {"fromDate": fromDate, "toDate": toDate});
    print(solarHeaterResponse.body);
    return json.decode(solarHeaterResponse.body) as List;
  }

  // Flow rates
  static const flow1 = 'Flow_rate1';
  static const flow2 = 'Flow_rate2';

  static Future<List> queryFlowData(
      {required String fromDate, required String toDate}) async {
    final flowMeterResponse =
        await http.get(Uri.parse('$firebaseDbUrl/cbes_data/flow.json'));
    return json.decode(flowMeterResponse.body) as List;
  }

  // Duct Data
  static const temperature = 'Temperature';
  static const humidity = 'Humidity';

  static Future<List> queryDuctData(
      {required String fromDate, required String toDate}) async {
    final ductMeterResponse =
        await http.get(Uri.parse('$firebaseDbUrl/cbes_data/ubibot.json'));
    // print(ductMeterResponse.body);
    return json.decode(ductMeterResponse.body) as List;
  }
}
