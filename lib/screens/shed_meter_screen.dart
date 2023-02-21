import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_data.dart';
import '../models/graph_axis.dart';
import '../providers/https_protocol.dart';
import '../providers/mqtt.dart';
import '../widgets/iot_page_template.dart';
import '../widgets/generate_excel_from_list.dart';
import '../widgets/radial_gauge_sf.dart';
import '../widgets/tank_graph.dart';
import './home_screen.dart';

class ShedMeterScreen extends StatefulWidget {
  const ShedMeterScreen({Key? key}) : super(key: key);

  @override
  State<ShedMeterScreen> createState() => _ShedMeterScreenState();
}

class _ShedMeterScreenState extends State<ShedMeterScreen> {
  var _online = true;
  final _fromDate = TextEditingController();
  final _toDate = TextEditingController();
  final List<GraphAxis> shedTemperatureHistoryGraphData = [];
  final List<GraphAxis> shedHumidityHistoryGraphData = [];

  var _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _fromDate.dispose();
    _toDate.dispose();
  }

  static const keyMain = "Datetime";
  static const key1 = "Temperature (°C)";
  static const key2 = "Humidity (%)";

  bool _onlineBnStatus(bool isOnline) {
    setState(() {
      _online = isOnline;
    });
    return isOnline;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      return Consumer<MqttProvider>(builder: (context, mqttProv, child) {
        final List<Map<String, String>> heatingUnitData = [
          {
            'title': 'Temperature',
            'data': mqttProv.shedMeterData?.temperature ?? '_._'
          },
          {
            'title': 'Humidity',
            'data': mqttProv.shedMeterData?.humidity ?? '_._'
          },
        ];
        return IotPageTemplate(
          loadingStatus: _isLoading,
          onlineBnStatus: _onlineBnStatus,
          gaugePart: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: heatingUnitData
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
                                title: e['title']!,
                                data: e['data'] == '_._' ? '0.0' : e['data']!,
                                minValue: 0.0,
                                maxValue: 100.0,
                                range1Value: 20.0,
                                range2Value: 55.0,
                                units: e['title'] == 'Temperature' ? '°C' : '%',
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList()),
          graphPart: MworiaGraph(
            axisTitle: "Temp (°C) and Humidity (%)",
            spline1Title: "Temperature (°C)",
            spline1DataSource: !_online
                ? shedTemperatureHistoryGraphData
                : mqttProv.shedTempGraphData,
            spline2Title: "Humidity (%)",
            spline2DataSource: !_online
                ? shedHumidityHistoryGraphData
                : mqttProv.shedHumidityGraphData,
            graphTitle: 'Graph of Temperature and Humidity against Time',
          ),
          fromController: _fromDate,
          toController: _toDate,
          generateExcel: () async {
            setState(() {
              _isLoading = true;
            });
            List shedDataCombination = [];
            int i = 0;
            if (_online) {
              for (var data in mqttProv.shedTempGraphData) {
                shedDataCombination.add({
                  keyMain: data.x,
                  key1: data.y,
                  key2: mqttProv.shedHumidityGraphData[i].y,
                });
                i += 1;
              }
            } else {
              for (var data in shedTemperatureHistoryGraphData) {
                shedDataCombination.add({
                  keyMain: data.x,
                  key1: data.y,
                  key2: shedHumidityHistoryGraphData[i].y,
                });
                i += 1;
              }
            }

            try {
              final fileBytes = await GenerateExcelFromList(
                listData: shedDataCombination,
                keyMain: keyMain,
                key1: key1,
                key2: key2,
              ).generateExcel();
              var directory = await getApplicationDocumentsDirectory();
              File(
                  ("${directory.path}/CBES/${HomeScreen.pageTitle(PageTitle.shedMeter)}/${DateFormat(GenerateExcelFromList.excelFormat).format(DateTime.now())}.xlsx"))
                ..createSync(recursive: true)
                ..writeAsBytesSync(fileBytes);
              Future.delayed(Duration.zero).then((value) async =>
                  await customDialog(
                      context, "Excel file generated successfully"));
            } catch (e) {
              await customDialog(context, "Error generating Excel file");
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          },
          searchDatabase: () async {
            setState(() {
              _isLoading = true;
            });
            try {
              final shedMeterHistoricalData =
                  await HttpProtocol.queryShedMeterData(
                      fromDate: _fromDate.text, toDate: _toDate.text);
              shedTemperatureHistoryGraphData.clear();
              shedHumidityHistoryGraphData.clear();
              // print(shedMeterHistoricalData);

              for (Map data in shedMeterHistoricalData) {
                shedTemperatureHistoryGraphData.add(GraphAxis(
                    data.keys.toList()[0],
                    (data.values.toList()[0][HttpProtocol.shedTemp])));
                shedHumidityHistoryGraphData.add(GraphAxis(
                    data.keys.toList()[0],
                    (data.values.toList()[0][HttpProtocol.shedHumidity])));
              }
              mqttProv.refresh();
            } catch (e) {
              await customDialog(
                  context, "Check data formatting from the database");
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          },
          activateExcel:
              (!_online && shedTemperatureHistoryGraphData.isNotEmpty) ||
                  (mqttProv.shedTempGraphData.isNotEmpty && _online),
        );
      });
    });
  }
}
