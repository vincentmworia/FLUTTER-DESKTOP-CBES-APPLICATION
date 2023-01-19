import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mqtt.dart';
import './linear_gauge.dart';
import './radial_gauge_kd.dart';

class DashboardScreenHeatingUnitConsumer extends StatelessWidget {
  const DashboardScreenHeatingUnitConsumer(
      {Key? key, required this.width, required this.height})
      : super(key: key);
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Consumer<MqttProvider>(
        builder: (context, mqttProv, child) => Row(
          children: [
            LinearGauge(
                title: 'Tank 1',
                data: mqttProv.heatingUnitData?.tank1,
                gaugeWidth: width * 0.075),
            LinearGauge(
                title: 'Tank 2',
                data: mqttProv.heatingUnitData?.tank2,
                gaugeWidth: width * 0.075),
            LinearGauge(
                title: 'Tank 3',
                data: mqttProv.heatingUnitData?.tank3,
                gaugeWidth: width * 0.075),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                KdRadialGauge(
                    title: 'Tank 1',
                    data: mqttProv.heatingUnitData?.flow1,
                    gaugeHeight: height * 0.15,units: 'lpm'),
                KdRadialGauge(
                    title: 'Tank 2',
                    data: mqttProv.heatingUnitData?.flow2,
                    gaugeHeight: height * 0.15,units: 'lpm'),
              ],
            ))
          ],
        ),
      );
}
