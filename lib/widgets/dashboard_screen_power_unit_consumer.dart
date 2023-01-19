import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mqtt.dart';
import '../helpers/global_data.dart';

class DashboardScreenPowerUnitConsumer extends StatelessWidget {
  const DashboardScreenPowerUnitConsumer(
      {Key? key, required this.width, required this.height})
      : super(key: key);
  final double width;
  final double height;
  static const ratio = 0.25;

  @override
  Widget build(BuildContext context) => Consumer<MqttProvider>(
        builder: (context, mqttProv, child) {
          final List<Map<String, dynamic>> powerUnitData = [
            {
              'titleMain': 'Grid Ac',
              'title1': 'Voltage',
              'data1': '${mqttProv.powerUnitData?.acVoltage ?? '0.0'} V',
              'title2': 'Frequency',
              'data2': '${mqttProv.powerUnitData?.acFrequency ?? '0.0'} Hz',
            },
            {
              'titleMain': 'Solar Pv',
              'title1': 'Voltage',
              'data1': '${mqttProv.powerUnitData?.pvInputVoltage ?? '0.0'} V',
              'title2': 'Power',
              'data2': '${mqttProv.powerUnitData?.pvInputPower ?? '0.0'} W',
            },
            {
              'titleMain': 'Battery',
              'title1': 'Voltage',
              'data1': '${mqttProv.powerUnitData?.batteryVoltage ?? '0.0'} V',
              'title2': 'Capacity',
              'data2': '${mqttProv.powerUnitData?.batteryCapacity ?? '0.0'} V',
              'title3': 'Charging',
              'data3': '${mqttProv.powerUnitData?.batteryVoltage ?? '0.0'} A',
              'title4': 'Discharge',
              'data4': '${mqttProv.powerUnitData?.batteryCapacity ?? '0.0'} A',
            },
            {
              'titleMain': 'Output',
              'title1': 'Apparent',
              'data1':
                  '${mqttProv.powerUnitData?.outputApparentPower ?? '0.0'} W',
              'title2': 'Active',
              'data2':
                  '${mqttProv.powerUnitData?.outputActivePower ?? '0.0'} W',
              'title3': 'Voltage',
              'data3': '${mqttProv.powerUnitData?.outputVoltage ?? '0.0'} V',
              'title4': 'Frequency',
              'data4': '${mqttProv.powerUnitData?.outputFrequency ?? '0.0'} Hz',
            },
          ];
          // todo RENDER THE TEXTS FROM MQTT

          Widget powerUnitItemData(String title, String data) => Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                        color: highColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      title,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
          Widget powerUnitItem(
                  {required String titleMain,
                  required String title1,
                  required String data1,
                  required String title2,
                  required String data2,
                  String? title3,
                  String? data3,
                  String? title4,
                  String? data4}) =>
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                width: title3 == null ? width / 8 : width / 4,
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      titleMain,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 3.0),
                    ),
                    Row(
                      children: [
                        powerUnitItemData(title1, data1),
                        powerUnitItemData(title2, data2),
                        if (title3 != null && data3 != null)
                          powerUnitItemData(title3, data3),
                        if (title4 != null && data4 != null)
                          powerUnitItemData(title4, data4),
                      ],
                    ),
                  ],
                ),
              );
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:  powerUnitData
                    .map((e) => powerUnitItem(
                          titleMain: e['titleMain'],
                          title1: e['title1'],
                          data1: e['data1'],
                          title2: e['title2'],
                          data2: e['data2'],
                          title3: e['title3'],
                          data3: e['data3'],
                          title4: e['title4'],
                          data4: e['data4'],
                        ))
                    .toList(),
              );
        },
      );
}
