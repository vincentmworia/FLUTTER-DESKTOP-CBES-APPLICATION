import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mqtt.dart';
import './radial_gauge_sf.dart';

class DashboardScreenEnvironmentMeterConsumer extends StatelessWidget {
  const DashboardScreenEnvironmentMeterConsumer(
      {Key? key, required this.width, required this.height})
      : super(key: key);
  final double width;
  final double height;
  static const ratio = 0.25;

  @override
  Widget build(BuildContext context) => Consumer<MqttProvider>(
        builder: (context, mqttProv, child) {
          final List<Map<String, dynamic>> environmentData = [
            {
              'title': 'Temperature',
              'units': '°C',
              'data': mqttProv.environmentMeterData?.temperature ?? '0.0',
              'minValue': 0.0,
              'maxValue': 100.0,
              'range1Value': 25.0,
              'range2Value': 55.0,
            },
            {
              'title': 'Humidity',
              'units': '%',
              'data': mqttProv.environmentMeterData?.humidity ?? '0.0',
              'minValue': 0.0,
              'maxValue': 100.0,
              'range1Value': 25.0,
              'range2Value': 55.0,
            },
            {
              'title': 'Illuminance',
              'units': 'lux',
              'data': mqttProv.environmentMeterData?.illuminance ?? '0.0',
              'minValue': 0.0,
              'maxValue': 100.0,
              'range1Value': 30.0,
              'range2Value': 70.0,
            },
          ];
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: environmentData
                  .map(
                    (e) => Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SyncfusionRadialGauge(
                        title: e['title'],
                        units: e['units'],
                        data: e['data'],
                        minValue: e['minValue'],
                        maxValue: e['maxValue'],
                        range1Value: e['range1Value'],
                        range2Value: e['range2Value'],
                      ),
                    )),
                  )
                  .toList());
        },
      );
}
