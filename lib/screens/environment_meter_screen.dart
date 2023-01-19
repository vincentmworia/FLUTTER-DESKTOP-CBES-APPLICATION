import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/radial_gauge_sf.dart';
import '../widgets/tank_graph.dart';
import '../providers/mqtt.dart';

class EnvironmentMeterScreen extends StatelessWidget {
  const EnvironmentMeterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("""
    Environment Energy SCREEN
      """),
    );
  }
}

//
//   static const _pageRatio = 0.3;
//
//   static const temperatureAndHumidityTitle = 'Temperature and Humidity';
//   static const illuminanceTitle = 'Illuminance';
//
//   static final bdRadius = BorderRadius.circular(10);
//
//   static Map<String, double> range100Data = {
//     'minValue': 0.0,
//     'maxValue': 100.0,
//     'range1Value': 25.0,
//     'range2Value': 55.0
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (_, cons) {
//       return Consumer<MqttProvider>(
//         builder: (context, mqttProv, child) {
//           final List<Map<String, dynamic>> environmentMeterData = [
//             {
//               'title': 'Temperature',
//               'units': '°C',
//               'data': mqttProv.environmentMeterData?.temperature ?? '0.0',
//               ...range100Data
//             },
//             {
//               'title': 'Humidity',
//               'units': '%',
//               'data': mqttProv.environmentMeterData?.humidity ?? '0.0',
//               ...range100Data
//             },
//             {
//               'title': 'Illuminance',
//               'units': 'lux',
//               'data': mqttProv.environmentMeterData?.illuminance ?? '0.0',
//               ...range100Data
//             },
//           ];
//           return Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: environmentMeterData
//                       .map((e) => Card(
//                             elevation: 8,
//                             shadowColor: Theme.of(context).colorScheme.primary,
//                             color: Colors.white.withOpacity(0.65),
//                             shape:
//                                 RoundedRectangleBorder(borderRadius: bdRadius),
//                             child: SizedBox(
//                               width: cons.maxWidth * _pageRatio * 0.7,
//                               height: cons.maxHeight * _pageRatio,
//                               child: SyncfusionRadialGauge(
//                                 title: e['title'],
//                                 units: e['units'],
//                                 data: e['data'],
//                                 minValue: e['minValue'],
//                                 maxValue: e['maxValue'],
//                                 range1Value: e['range1Value'],
//                                 range2Value: e['range2Value'],
//                               ),
//                             ),
//                           ))
//                       .toList()),
//               Row(
//                 children: [
//                   Expanded(
//                     // todo temp and humidity
//                     child: TankGraph(
//                       axisTitle: "Temp (°C) and Humidity (%)",
//                       spline1Title: "Temperature",
//                       spline1DataSource: mqttProv.temperatureGraphData,
//                       spline2Title: "Humidity",
//                       spline2DataSource: mqttProv.humidityGraphData,
//                     ),
//                   ),
//                   Expanded(
//                     child: TankGraph(
//                       axisTitle: "Illuminance lux",
//                       spline1Title: 'Illuminance',
//                       spline1DataSource: mqttProv.illuminanceGraphData,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           );
//         },
//       );
//     });
//   }
// }
