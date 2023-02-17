import 'dart:convert';

import 'package:cbesdesktop/private_data.dart';
import 'package:http/http.dart' as http;

class HttpProtocol {
  // Temperatures
  static const tank1 = 'Tank1';
  static const tank2 = 'Tank2';
  static const tank3 = 'Tank3';

  // http://52.36.201.129/cbes/tank_temp
  static List filterDbData(List data) {
    final elementsToBeRemoved = (data.length / 1000).floor();

    for (var i = 0; i < data.length; i++) {
      if ((i + elementsToBeRemoved) > data.length) {
        break;
      }
      data.removeRange(i, i + elementsToBeRemoved);
    }

    return data;
  }

  static Future<List> querySolarHeater(
      {required String fromDate, required String toDate}) async {
    final solarHeaterResponse =
        // await http.get(Uri.parse('$firebaseDbUrl/cbes_data/temperature.json'));
        await http.get(Uri.parse('$josephDbUrl/cbes/tank_temp'),
            headers: {"fromDate": fromDate, "toDate": toDate});
    final tempData = json.decode(solarHeaterResponse.body) as List;
    if (tempData.length > 1100) {
      filterDbData(tempData);
    }
    return tempData;
  }

  // Flow rates
  static const flow1 = 'Flow_rate1';
  static const flow2 = 'Flow_rate2';

  static Future<List> queryFlowData(
      {required String fromDate, required String toDate}) async {
    final flowMeterResponse =
        // await http.get(Uri.parse('$firebaseDbUrl/cbes_data/flow.json'));
        await http.get(Uri.parse('$josephDbUrl/cbes/flow_rates'),
            headers: {"fromDate": fromDate, "toDate": toDate});
    final tempData = json.decode(flowMeterResponse.body) as List;
    if (tempData.length > 1100) {
      filterDbData(tempData);
    }
    return tempData;
  }

  // Duct Data
  static const temperature = 'Temperature';
  static const humidity = 'Humidity';

  static Future<List> queryDuctData(
      {required String fromDate, required String toDate}) async {
    final ductMeterResponse =
        // await http.get(Uri.parse('$firebaseDbUrl/cbes_data/ubibot.json'));
        await http.get(Uri.parse('$josephDbUrl/cbes/ubibot'),
            headers: {"fromDate": fromDate, "toDate": toDate});
    final tempData = json.decode(ductMeterResponse.body) as List;
    if (tempData.length > 1100) {
      filterDbData(tempData);
    }
    return tempData;
  }

  // todo Switch to Joseph's Database
  // Thermal Energy

  static const waterThermal = "water";
  static const pvThermal = "pv";

  static Future<List> queryThermalEnergyData(
      {required String fromDate, required String toDate}) async {
    final thermalMeterResponse = await http
        .get(Uri.parse('$firebaseDbUrl/cbes_data/thermal_energy.json'));
    return json.decode(thermalMeterResponse.body) as List;
  }

  // Ambient Meter
  static const ambientTemp = "temp";
  static const ambientHumidity = "humidity";
  static const ambientIrradiance = "irradiance";

  static Future<List> queryAmbientMeter(
      {required String fromDate, required String toDate}) async {
    final thermalMeterResponse = await http
        .get(Uri.parse('$firebaseDbUrl/cbes_data/ambient_meter.json'));
    return json.decode(thermalMeterResponse.body) as List;
  }

  // Shed Meter
  static const shedTemp = "temp";
  static const shedHumidity = "humidity";

  static Future<List> queryShedMeterData(
      {required String fromDate, required String toDate}) async {
    final thermalMeterResponse = await http
        .get(Uri.parse('$firebaseDbUrl/cbes_data/shed_meter.json'));
    return json.decode(thermalMeterResponse.body) as List;
  }

  static Future<http.Response> getFirewoodData() async {
    return await http.get(Uri.parse('$firebaseDbUrl/cbes_data/firewood.json'));
  }

  static Future<void> addFirewoodStackData(
      {required String stackName,
      required Map<String, dynamic> newData}) async {
    print('2');
    final resp = await http.patch(
      Uri.parse('$firebaseDbUrl/cbes_data/firewood/$stackName.json'),
      // todo CHECK THE DATA TO BE ADDED
      body: json.encode(newData),
    );
    print(json.decode(resp.body));
  }

  static Future<void> deleteFirewoodStack(String stackName) async {
    await http
        .delete(Uri.parse('$firebaseDbUrl/cbes_data/firewood/$stackName.json'));
  }
}
