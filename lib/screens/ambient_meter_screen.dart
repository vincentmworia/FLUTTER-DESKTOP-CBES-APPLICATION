import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../providers/https_protocol.dart';
import '../widgets/search_toggle_view.dart';
import '../helpers/custom_data.dart';
import '../models/graph_axis.dart';
import '../widgets/iot_page_template.dart';
import '../widgets/linear_gauge.dart';
import '../widgets/tank_graph.dart';
import '../providers/mqtt.dart';
import '../widgets/generate_excel_from_list.dart';
import './home_screen.dart';

class AmbientMeterScreen extends StatefulWidget {
  const AmbientMeterScreen({Key? key}) : super(key: key);

  @override
  State<AmbientMeterScreen> createState() => _AmbientMeterScreenState();
}

class _AmbientMeterScreenState extends State<AmbientMeterScreen> {
  static const keyMain = "Datetime";
  static const key1 = "Ambient Temperature (°C)";
  static const key2 = "Ambient Humidity (%)";
  static const key3 = "Irradiance (w/m²)";

  var _online = true;
  var _isLoading = false;
  final _fromDate = TextEditingController();
  final _toDate = TextEditingController();

  final List<GraphAxis> ambientTempHistoryGraphData = [];
  final List<GraphAxis> ambientHumidityHistoryGraphData = [];
  final List<GraphAxis> irradianceHistoryGraphData = [];

  @override
  void dispose() {
    super.dispose();
    _fromDate.dispose();
    _toDate.dispose();
  }

  bool _onlineBnStatus(bool isOnline) {
    setState(() {
      _online = isOnline;
    });
    return isOnline;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (_, cons) =>
            Consumer<MqttProvider>(builder: (context, mqttProv, child) {
              final List<Map<String, String>> ambientMeterData = [
                {
                  'title': 'Temperature',
                  'data': (mqttProv.heatingUnitData?.ambientTemp)
                          ?.toStringAsFixed(1) ??
                      '0.0',
                  'min': '0.0',
                  'max': '100.0',
                  'units': '°C',
                },
                {
                  'title': 'Humidity',
                  'data': (mqttProv.heatingUnitData?.ambientHumidity)
                          ?.toStringAsFixed(1) ??
                      '0.0',
                  'min': '0.0',
                  'max': '100.0',
                  'units': '%',
                },
                {
                  'title': 'Irradiance',
                  'data': (mqttProv.heatingUnitData?.ambientIrradiance)
                          ?.toStringAsFixed(1) ??
                      '0.0',
                  'units': 'w/m²',
                  'min': '0.0',
                  'max': '2000.0',
                },
              ];
              return IotPageTemplate(
                loadingStatus: _isLoading,
                onlineBnStatus: _onlineBnStatus,
                fromController: _fromDate,
                toController: _toDate,
                gaugePart: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ambientMeterData
                        .map((e) => Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              color: Colors.white.withOpacity(0.85),
                              shadowColor:
                                  Theme.of(context).colorScheme.primary,
                              child: LinearGauge(
                                  title: e['title']!,
                                  data: e['data']!,
                                  min: double.parse(e['min']!),
                                  max: double.parse(e['max']!),
                                  units: e['units']!,
                                  gaugeWidth: cons.maxWidth * 0.075),
                            ))
                        .toList()),
                graphPart: MworiaGraph(
                  graphTitle: 'Graph of Ambience against Time',
                  axisTitle: "Temp (°C)",
                  spline1DataSource: !_online
                      ? ambientTempHistoryGraphData
                      : mqttProv.ambientTempGraphData,
                  spline1Title: "Ambient Temperature",
                  spline2DataSource: !_online
                      ? ambientHumidityHistoryGraphData
                      : mqttProv.ambientHumidityGraphData,
                  spline2Title: "Ambient Humidity",
                  spline3DataSource: !_online
                      ? irradianceHistoryGraphData
                      : mqttProv.ambientIrradianceGraphData,
                  spline3Title: "Ambient Irradiance",
                ),
                generateExcel: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  List ambientMeterDataCombination = [];
                  int i = 0;
                  if (_online) {
                    for (var data in mqttProv.ambientTempGraphData) {
                      ambientMeterDataCombination.add({
                        keyMain: data.x,
                        key1: data.y,
                        key2: mqttProv.ambientHumidityGraphData[i].y,
                        key3: mqttProv.ambientIrradianceGraphData[i].y,
                      });
                      i += 1;
                    }
                  } else {
                    for (var data in ambientTempHistoryGraphData) {
                      ambientMeterDataCombination.add({
                        keyMain: data.x,
                        key1: data.y,
                        key2: ambientHumidityHistoryGraphData[i].y,
                        key3: irradianceHistoryGraphData[i].y,
                      });
                      i += 1;
                    }
                  }

                  try {
                    final fileBytes = await GenerateExcelFromList(
                      listData: ambientMeterDataCombination,
                      keyMain: keyMain,
                      key1: key1,
                      key2: key2,
                      key3: key3,
                    ).generateExcel();
                    var directory = await getApplicationDocumentsDirectory();
                    File(
                        ("${directory.path}/CBES/${HomeScreen.pageTitle(PageTitle.ambientMeter)}/${DateFormat(GenerateExcelFromList.excelFormat).format(DateTime.now())}.xlsx"))
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
                    // todo Get the ambient temp, humidity, irradiance of the database
                    final ambientMeterHeaterHistoricalData =
                        await HttpProtocol.queryAmbientMeter(
                            fromDate: _fromDate.text, toDate: _toDate.text);
                    ambientTempHistoryGraphData.clear();
                    ambientHumidityHistoryGraphData.clear();
                    irradianceHistoryGraphData.clear();
                    for (Map data in ambientMeterHeaterHistoricalData) {
                      ambientTempHistoryGraphData.add(GraphAxis(
                          data.keys.toList()[0],
                          (data.values.toList()[0][HttpProtocol.ambientTemp])));
                      ambientHumidityHistoryGraphData.add(GraphAxis(
                          data.keys.toList()[0],
                          (data.values.toList()[0]
                              [HttpProtocol.ambientHumidity])));
                      irradianceHistoryGraphData.add(GraphAxis(
                          data.keys.toList()[0],
                          (data.values.toList()[0]
                              [HttpProtocol.ambientIrradiance])));
                    }
                    mqttProv.refresh();
                  } catch (e) {
                    await customDialog(
                        context, "Check data formatting from the database");
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                activateExcel:
                    (!_online && ambientTempHistoryGraphData.isNotEmpty) ||
                        (_online && mqttProv.ambientTempGraphData.isNotEmpty),
              );
            }));
  }
}
