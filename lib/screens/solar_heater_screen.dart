import 'dart:io';

import 'package:cbesdesktop/providers/https_protocol.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../helpers/custom_data.dart';
import '../models/graph_axis.dart';
import '../widgets/IotPageTemplate.dart';
import '../widgets/linear_gauge.dart';
import '../widgets/loading_animation.dart';
import '../widgets/tank_graph.dart';
import '../providers/mqtt.dart';
import './home_screen.dart';
import '../widgets/generate_excel_from_list.dart';

class HeatingUnitScreen extends StatefulWidget {
  const HeatingUnitScreen({Key? key}) : super(key: key);

  @override
  State<HeatingUnitScreen> createState() => _HeatingUnitScreenState();
}

class _HeatingUnitScreenState extends State<HeatingUnitScreen> {
  static const keyMain = "Datetime";
  static const key1 = "Tank 1 temperature";
  static const key2 = "Tank 2 temperature";
  static const key3 = "Tank 3 temperature";
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
    return LayoutBuilder(builder: (_, cons) {
      return Consumer<MqttProvider>(builder: (context, mqttProv, child) {
        final List<Map<String, String>> heatingUnitData = [
          {'title': 'Tank 1', 'data': mqttProv.heatingUnitData?.tank1 ?? '0.0'},
          {'title': 'Tank 2', 'data': mqttProv.heatingUnitData?.tank2 ?? '0.0'},
          {'title': 'Tank 3', 'data': mqttProv.heatingUnitData?.tank3 ?? '0.0'},
        ];
        // if (_isLoading) {
        //   return const MyLoadingAnimation();
        // }
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
                        shadowColor: Theme.of(context).colorScheme.primary,
                        child: LinearGauge(
                            title: e['title'],
                            data: e['data'],
                            gaugeWidth: cons.maxWidth * 0.075),
                      ))
                  .toList()),
          graphPart: TankGraph(
            graphTitle: 'Graph of Temperature against Time',
            axisTitle: "Temp (°C)",
            spline1DataSource:
                !_online ? temp1HistoryGraphData : mqttProv.temp1GraphData,
            spline1Title: "Tank 1",
            spline2DataSource:
                !_online ? temp2HistoryGraphData : mqttProv.temp2GraphData,
            spline2Title: "Tank 2",
            spline3DataSource:
                !_online ? temp3HistoryGraphData : mqttProv.temp3GraphData,
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
                  keyMain: data.x.split(':'),
                  key1: data.y,
                  key2: mqttProv.temp2GraphData[i].y,
                  key3: mqttProv.temp3GraphData[i].y
                });
                i += 1;
              }
            } else {
              for (var data in temp1HistoryGraphData) {
                final subDate = (data.x.split(':')
                  ..removeRange(2, 4)
                  ..join(":")) as String;

                tempDataCombination.add({
                  keyMain: subDate,
                  key1: data.y,
                  key2: temp2HistoryGraphData[i].y,
                  key3: temp3HistoryGraphData[i].y
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
              ).generateExcel();
              var directory = await getApplicationDocumentsDirectory();
              File(
                  ("${directory.path}/CBES/${HomeScreen.pageTitle(PageTitle.solarHeaterMeter)}/${DateFormat('dd-MMM-yyyy HH-mm').format(DateTime.now())}.xlsx"))
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
          searchDatabase: (_fromDate.text == "" ||
                  _toDate.text == "" ||
                  DateTime.parse(_fromDate.text)
                      .isAfter(DateTime.parse(_toDate.text)))
              ? null
              : () async {
                  if (DateTime.parse(_fromDate.text)
                      .isAfter(DateTime.parse(_toDate.text))) {
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
                      temp1HistoryGraphData.add(GraphAxis(data.keys.toList()[0],
                          data.values.toList()[0]['Tank1']));
                      temp2HistoryGraphData.add(GraphAxis(data.keys.toList()[0],
                          data.values.toList()[0]['Tank2']));
                      temp3HistoryGraphData.add(GraphAxis(data.keys.toList()[0],
                          data.values.toList()[0]['Tank3']));
                    }
                    mqttProv.refresh();
                  } catch (e) {
                    print(e.toString());
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
        );
      });
    });
  }
}
