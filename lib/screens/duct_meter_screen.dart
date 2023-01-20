import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_data.dart';
import '../providers/mqtt.dart';
import '../widgets/IotPageTemplate.dart';
import '../widgets/generate_excel_from_list.dart';
import '../widgets/radial_gauge_sf.dart';
import '../widgets/tank_graph.dart';
import 'home_screen.dart';

class DuctMeterScreen extends StatefulWidget {
  const DuctMeterScreen({Key? key}) : super(key: key);

  @override
  State<DuctMeterScreen> createState() => _DuctMeterScreenState();
}

class _DuctMeterScreenState extends State<DuctMeterScreen> {
  var _online = true;
  static const keyMain = "Datetime";
  static const key1 = "Duct Temperature";
  static const key2 = "Duct Humidity";

  bool _onlineBnStatus(bool isOnline) {
    setState(() {
      _online = isOnline;
    });
    return isOnline;
  }

  static Map<String, double> range100Data = {
    'minValue': 0.0,
    'maxValue': 100.0,
    'range1Value': 25.0,
    'range2Value': 55.0
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      return Consumer<MqttProvider>(builder: (context, mqttProv, child) {
        final List<Map<String, dynamic>> environmentMeterData = [
          {
            'title': 'Temperature',
            'units': '°C',
            'data': mqttProv.ductMeterData?.temperature ?? '0.0',
            ...range100Data
          },
          {
            'title': 'Humidity',
            'units': '%',
            'data': mqttProv.ductMeterData?.humidity ?? '0.0',
            ...range100Data
          },
        ];
        return IotPageTemplate(
          onlineBnStatus: _onlineBnStatus,
          // gaugePart: Container(),
          gaugePart: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: environmentMeterData
                  .map((e) => Expanded(
                        child: Container(
                          margin: EdgeInsets.all(cons.maxWidth * 0.02),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            color: Colors.white.withOpacity(0.85),
                            shadowColor: Theme.of(context).colorScheme.primary,
                            child: SizedBox(
                              width: 175,
                              height: double.infinity,
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
                          ),
                        ),
                      ))
                  .toList()),
          graphPart: TankGraph(
            axisTitle: "Temp (°C) and Humidity (%)",
            spline1Title: "Temperature",
            spline1DataSource: !_online ? [] : mqttProv.temperatureGraphData,
            spline2Title: "Humidity",
            spline2DataSource: !_online ? [] : mqttProv.humidityGraphData,
            graphTitle: 'Graph of Temperature and Humidity against Time',
          ),
          generateExcel: () async {
            List tempDataCombination = [];
            int i = 0;
            for (var data in mqttProv.flow1GraphData) {
              tempDataCombination.add({
                keyMain: data.x,
                key1: data.y,
                key2: mqttProv.flow2GraphData[i].y,
              });
              i += 1;
            }

            try {
              final fileBytes = await GenerateExcelFromList(
                listData: tempDataCombination,
                keyMain: keyMain,
                key1: key1,
                key2: key2,
              ).generateExcel();
              var directory = await getApplicationDocumentsDirectory();
              File(
                  ("${directory.path}/CBES/${HomeScreen.pageTitle(PageTitle.ductMeter)}/${DateFormat('dd-MMM-yyyy HH-mm-ss').format(DateTime.now())}.xlsx"))
                ..createSync(recursive: true)
                ..writeAsBytesSync(fileBytes);
              Future.delayed(Duration.zero).then((value) async =>
                  await customDialog(
                      context, "Excel file generated successfully"));
            } catch (e) {
              await customDialog(context, "Error generating Excel file");
            }
          },
        );
      });
    });
  }
}
