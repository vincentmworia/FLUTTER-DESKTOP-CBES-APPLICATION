import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/radial_gauge_sf.dart';
import '../widgets/tank_graph.dart';
import '../providers/mqtt.dart';

class ElectricalEnergyScreen extends StatelessWidget {
  const ElectricalEnergyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("""
     Electrical Energy SCREEN
     - PV Power
     - Output Power 
     - Grid Power =Output Power - PV Power
      """),
    );
  }
}

/*

  static const _pageRatio = 0.25;

  static const temperatureAndHumidityTitle = 'Temperature and Humidity';
  static const illuminanceTitle = 'Illuminance';

  static final bdRadius = BorderRadius.circular(10);
  static const Map<String, dynamic> voltageData = {
    'minValue': 0.0,
    'maxValue': 500.0,
    'range1Value': 200.0,
    'range2Value': 265.0,
    'units': 'V',
  };
  static const Map<String, dynamic> frequencyData = {
    'minValue': 0.0,
    'maxValue': 100.0,
    'range1Value': 45.0,
    'range2Value': 55.0,
    'units': 'Hz',
  };
  static const Map<String, dynamic> powerData = {
    'units': 'W',
    'minValue': 0.0,
    'maxValue': 100.0,
    'range1Value': 25.0,
    'range2Value': 55.0,
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      return Consumer<MqttProvider>(
        builder: (context, mqttProv, child) {
          final List<Map<String, dynamic>> environmentMeterData1 = [
            {
              'title': 'Grid Voltage',
              'data': mqttProv.powerUnitData?.acVoltage ?? '0.0',
              ...voltageData
            },
            {
              'title': 'Output Active Power',
              'data': mqttProv.powerUnitData?.outputActivePower ?? '0.0',
              ...powerData
            },
            {
              'title': 'Battery Voltage',
              'units': 'V',
              'data': mqttProv.powerUnitData?.batteryVoltage ?? '0.0',
              'minValue': 0.0,
              'maxValue': 100.0,
              'range1Value': 35.0,
              'range2Value': 65.0,
            },
          ];
          final List<Map<String, dynamic>> environmentMeterData2 = [
            {
              'title': 'Pv Voltage',
              'data': mqttProv.powerUnitData?.pvInputVoltage ?? '0.0',
              ...voltageData
            },
            {
              'title': 'Output Apparent Power',
              'data': mqttProv.powerUnitData?.outputApparentPower ?? '0.0',
              ...powerData
            },
            {
              'title': 'Battery Capacity',
              'data': mqttProv.powerUnitData?.batteryCapacity ?? '0.0',
              'minValue': 0.0,
              'maxValue': 100.0,
              'range1Value': 25.0,
              'range2Value': 65.0,
              'units': 'V',
            },
          ];

          final List<Map<String, dynamic>> environmentMeterData3 = [
            {
              'title': 'Output Voltage',
              'data': mqttProv.powerUnitData?.outputVoltage ?? '0.0',
              ...voltageData
            },
            {
              'title': 'Pv Power',
              'data': mqttProv.powerUnitData?.pvInputPower ?? '0.0',
              ...powerData
            },
            {
              'title': 'Grid Frequency',
              'data': mqttProv.powerUnitData?.acFrequency ?? '0.0',
              ...frequencyData
            },
          ];

          // todo add Battery Capacity data
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: environmentMeterData1
                        .map((e) => Card(
                              elevation: 8,
                              shadowColor:
                                  Theme.of(context).colorScheme.primary,
                              color: Colors.white.withOpacity(0.65),
                              shape: RoundedRectangleBorder(
                                  borderRadius: bdRadius),
                              child: SizedBox(
                                width: cons.maxWidth * _pageRatio * 0.7,
                                height: cons.maxHeight * _pageRatio,
                                child: SyncfusionRadialGauge(
                                  title: e['title'],
                                  units: e['units'],
                                  data: e['data'],
                                  minValue: e['minValue'],
                                  maxValue: e['maxValue'],
                                  range1Value: e['range1Value'],
                                  range2Value: e['range2Value'],
                                ),
                              ),
                            ))
                        .toList()),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: environmentMeterData2
                        .map((e) => Card(
                              elevation: 8,
                              shadowColor:
                                  Theme.of(context).colorScheme.primary,
                              color: Colors.white.withOpacity(0.65),
                              shape: RoundedRectangleBorder(
                                  borderRadius: bdRadius),
                              child: SizedBox(
                                width: cons.maxWidth * _pageRatio * 0.7,
                                height: cons.maxHeight * _pageRatio,
                                child: SyncfusionRadialGauge(
                                  title: e['title'],
                                  units: e['units'],
                                  data: e['data'],
                                  minValue: e['minValue'],
                                  maxValue: e['maxValue'],
                                  range1Value: e['range1Value'],
                                  range2Value: e['range2Value'],
                                ),
                              ),
                            ))
                        .toList()),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: environmentMeterData3
                        .map((e) => Card(
                              elevation: 8,
                              shadowColor:
                                  Theme.of(context).colorScheme.primary,
                              color: Colors.white.withOpacity(0.65),
                              shape: RoundedRectangleBorder(
                                  borderRadius: bdRadius),
                              child: SizedBox(
                                width: cons.maxWidth * _pageRatio * 0.7,
                                height: cons.maxHeight * _pageRatio,
                                child: SyncfusionRadialGauge(
                                  title: e['title'],
                                  units: e['units'],
                                  data: e['data'],
                                  minValue: e['minValue'],
                                  maxValue: e['maxValue'],
                                  range1Value: e['range1Value'],
                                  range2Value: e['range2Value'],
                                ),
                              ),
                            ))
                        .toList()),
              ),
              Expanded(
                child: TankGraph(
                  axisTitle: "Voltage (V)",
                  area1Title: "Output Power",
                  area1DataSource: mqttProv.outputActivePowerGraphData,
                  area2Title: "Pv Power",
                  area2DataSource: mqttProv.pvPowerGraphData,
                  // area3Title: "Output Voltage",
                  // area3DataSource: mqttProv.outputVoltageGraphData,
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
*/
