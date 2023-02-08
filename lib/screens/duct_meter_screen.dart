import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_data.dart';
import '../models/graph_axis.dart';
import '../providers/https_protocol.dart';
import '../providers/mqtt.dart';
import '../widgets/Iot_page_template.dart';
import '../widgets/generate_excel_from_list.dart';
import '../widgets/radial_gauge_sf.dart';
import '../widgets/search_toggle_view.dart';
import '../widgets/tank_graph.dart';
import './home_screen.dart';

class DuctMeterScreen extends StatefulWidget {
  const DuctMeterScreen({Key? key}) : super(key: key);

  @override
  State<DuctMeterScreen> createState() => _DuctMeterScreenState();
}

class _DuctMeterScreenState extends State<DuctMeterScreen> {
  var _online = true;
  final _fromDate = TextEditingController();
  final _toDate = TextEditingController();

  final List<GraphAxis> ductTemperatureHistoryGraphData = [];
  final List<GraphAxis> ductHumidityHistoryGraphData = [];

  @override
  void dispose() {
    super.dispose();
    _fromDate.dispose();
    _toDate.dispose();
  }

  static const keyMain = "Datetime";
  static const key1 = "Duct Temperature";
  static const key2 = "Duct Humidity";

  var _isLoading = false;

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
          loadingStatus: _isLoading,
          onlineBnStatus: _onlineBnStatus,
          fromController: _fromDate,
          toController: _toDate,
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
          graphPart: MworiaGraph(
            axisTitle: "Temp (°C) and Humidity (%)",
            spline1Title: "Temperature",
            spline1DataSource: !_online
                ? ductTemperatureHistoryGraphData
                : mqttProv.temperatureGraphData,
            spline2Title: "Humidity",
            spline2DataSource: !_online
                ? ductHumidityHistoryGraphData
                : mqttProv.humidityGraphData,
            graphTitle: 'Graph of Temperature and Humidity against Time',
          ),

          generateExcel: () async {
            setState(() {
              _isLoading = true;
            });
            List ductDataCombination = [];
            int i = 0;
            if (_online) {
              for (var data in mqttProv.temperatureGraphData) {
                ductDataCombination.add({
                  keyMain: data.x,
                  key1: data.y,
                  key2: mqttProv.humidityGraphData[i].y,
                });
                i += 1;
              }
            } else {
              for (var data in ductTemperatureHistoryGraphData) {
                ductDataCombination.add({
                  keyMain: data.x,
                  key1: data.y,
                  key2: ductHumidityHistoryGraphData[i].y,
                });
                i += 1;
              }
            }

            try {
              final fileBytes = await GenerateExcelFromList(
                listData: ductDataCombination,
                keyMain: keyMain,
                key1: key1,
                key2: key2,
              ).generateExcel();
              var directory = await getApplicationDocumentsDirectory();
              File(
                  ("${directory.path}/CBES/${HomeScreen.pageTitle(PageTitle.ductMeter)}/${DateFormat('EEE, MMM d yyyy  hh mm a').format(DateTime.now())}.xlsx"))
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
            if (SearchToggleView.fromDateVal!
                .isAfter(SearchToggleView.toDateVal!)) {
              await customDialog(
                  context, "Make sure the time in 'To' is after 'From'");
              return;
            }
            setState(() {
              _isLoading = true;
            });
            try {
              final ductMeterHistoricalData = await HttpProtocol.queryDuctData(
                  fromDate: _fromDate.text, toDate: _toDate.text);
              ductTemperatureHistoryGraphData.clear();
              ductHumidityHistoryGraphData.clear();

              for (Map data in ductMeterHistoricalData) {
                ductTemperatureHistoryGraphData.add(GraphAxis(
                    data.keys.toList()[0],
                    double.parse(
                        '${(data.values.toList()[0][HttpProtocol.temperature]).toString()}.0')));
                ductHumidityHistoryGraphData.add(GraphAxis(
                    data.keys.toList()[0],
                    double.parse(
                        '${(data.values.toList()[0][HttpProtocol.humidity]).toString()}.0')));
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
              (!_online && ductTemperatureHistoryGraphData.isNotEmpty) ||
                  (mqttProv.temperatureGraphData.isNotEmpty && _online), formKey: GlobalKey<FormState>(),
        );
      });
    });
  }
}
