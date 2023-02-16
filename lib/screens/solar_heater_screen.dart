import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../providers/https_protocol.dart';
import '../widgets/search_toggle_view.dart';
import '../helpers/custom_data.dart';
import '../models/graph_axis.dart';
import '../widgets/Iot_page_template.dart';
import '../widgets/linear_gauge.dart';
import '../widgets/tank_graph.dart';
import '../providers/mqtt.dart';
import '../widgets/generate_excel_from_list.dart';
import './home_screen.dart';

class HeatingUnitScreen extends StatefulWidget {
  const HeatingUnitScreen({Key? key}) : super(key: key);

  @override
  State<HeatingUnitScreen> createState() => _HeatingUnitScreenState();
}

class _HeatingUnitScreenState extends State<HeatingUnitScreen> {
  static const keyMain = "Datetime";
  static const key1 = "Tank 1 temperature (°C)";
  static const key2 = "Tank 2 temperature (°C)";
  static const key3 = "Tank 3 temperature (°C)";
  static const key4 = "Average temperature (°C)";
  var _online = true;
  var _isLoading = false;
  final _fromDate = TextEditingController();
  final _toDate = TextEditingController();

  final List<GraphAxis> temp1HistoryGraphData = [];
  final List<GraphAxis> temp2HistoryGraphData = [];
  final List<GraphAxis> temp3HistoryGraphData = [];

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
              final List<Map<String, String>> heatingUnitData = [
                {
                  'title': 'Tank 1 ',
                  'data': mqttProv.heatingUnitData?.tank1 ?? '0.0'
                },
                {
                  'title': 'Tank 2',
                  'data': mqttProv.heatingUnitData?.tank2 ?? '0.0'
                },
                {
                  'title': 'Tank 3',
                  'data': mqttProv.heatingUnitData?.tank3 ?? '0.0'
                },
              ];
              return IotPageTemplate(
                loadingStatus: _isLoading,
                onlineBnStatus: _onlineBnStatus,
                fromController: _fromDate,
                toController: _toDate,
                gaugePart: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: heatingUnitData
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
                                  min: 0.0,
                                  max: 100.0,
                                  units: '°C',
                                  gaugeWidth: cons.maxWidth * 0.075),
                            ))
                        .toList()),
                graphPart: MworiaGraph(
                  graphTitle: 'Graph of Temperature against Time',
                  axisTitle: "Temp (°C)",
                  spline1DataSource: !_online
                      ? temp1HistoryGraphData
                      : mqttProv.temp1GraphData,
                  spline1Title: "Tank 1",
                  spline2DataSource: !_online
                      ? temp2HistoryGraphData
                      : mqttProv.temp2GraphData,
                  spline2Title: "Tank 2",
                  spline3DataSource: !_online
                      ? temp3HistoryGraphData
                      : mqttProv.temp3GraphData,
                  spline3Title: "Tank 3",
                ),
                generateExcel: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  List tempDataCombination = [];
                  int i = 0;
                  if (_online) {
                    for (var data in mqttProv.temp1GraphData) {
                      tempDataCombination.add({
                        keyMain: data.x,
                        key1: data.y,
                        key2: mqttProv.temp2GraphData[i].y,
                        key3: mqttProv.temp3GraphData[i].y,
                        key4: (data.y +
                                mqttProv.temp2GraphData[i].y +
                                mqttProv.temp3GraphData[i].y) /
                            3
                      });
                      i += 1;
                    }
                  } else {
                    for (var data in temp1HistoryGraphData) {
                      tempDataCombination.add({
                        keyMain: data.x,
                        key1: data.y,
                        key2: temp2HistoryGraphData[i].y,
                        key3: temp3HistoryGraphData[i].y,
                        key4: (data.y +
                                temp2HistoryGraphData[i].y +
                                temp3HistoryGraphData[i].y) /
                            3
                      });
                      i += 1;
                    }
                  }

                  try {
                    final fileBytes = await GenerateExcelFromList(
                      listData: tempDataCombination,
                      keyMain: keyMain,
                      key1: key1,
                      key2: key2,
                      key3: key3,
                      key4: key4,
                    ).generateExcel();
                    var directory = await getApplicationDocumentsDirectory();
                    File(
                        ("${directory.path}/CBES/${HomeScreen.pageTitle(PageTitle.solarHeaterMeter)}/${DateFormat(GenerateExcelFromList.excelFormat).format(DateTime.now())}.xlsx"))
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
                    final solarHeaterHistoricalData =
                        await HttpProtocol.querySolarHeater(
                            fromDate: _fromDate.text, toDate: _toDate.text);
                    temp1HistoryGraphData.clear();
                    temp2HistoryGraphData.clear();
                    temp3HistoryGraphData.clear();
                    for (Map data in solarHeaterHistoricalData) {
                      temp1HistoryGraphData.add(GraphAxis(
                          data.keys.toList()[0],
                          double.parse(
                              '${(data.values.toList()[0][HttpProtocol.tank1]).toString()}.0')));
                      temp2HistoryGraphData.add(GraphAxis(
                          data.keys.toList()[0],
                          double.parse(
                              '${(data.values.toList()[0][HttpProtocol.tank2]).toString()}.0')));
                      temp3HistoryGraphData.add(GraphAxis(
                          data.keys.toList()[0],
                          double.parse(
                              '${(data.values.toList()[0][HttpProtocol.tank3]).toString()}.0')));
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
                activateExcel: (!_online && temp1HistoryGraphData.isNotEmpty) ||
                    (_online && mqttProv.temp1GraphData.isNotEmpty),
              );
            }));
  }
}
