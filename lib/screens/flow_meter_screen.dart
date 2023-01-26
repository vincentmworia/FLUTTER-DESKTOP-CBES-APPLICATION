import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_data.dart';
import '../models/graph_axis.dart';
import '../providers/https_protocol.dart';
import '../providers/mqtt.dart';
import '../widgets/IotPageTemplate.dart';
import '../widgets/generate_excel_from_list.dart';
import '../widgets/radial_gauge_sf.dart';
import '../widgets/tank_graph.dart';
import './home_screen.dart';

class FlowMeterScreen extends StatefulWidget {
  const FlowMeterScreen({Key? key}) : super(key: key);

  @override
  State<FlowMeterScreen> createState() => _FlowMeterScreenState();
}

class _FlowMeterScreenState extends State<FlowMeterScreen> {
  var _online = true;
  final _fromDate = TextEditingController();
  final _toDate = TextEditingController();
  final List<GraphAxis> flow1HistoryGraphData = [];
  final List<GraphAxis> flow2HistoryGraphData = [];

  var _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _fromDate.dispose();
    _toDate.dispose();
  }

  static const keyMain = "Datetime";
  static const key1 = "Flow Rate (To Solar Heater)";
  static const key2 = "Flow Rate (To Heat Exchanger)";

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
            'title': 'Flow S.H',
            'data': mqttProv.heatingUnitData?.flow2 ?? '0.0'
          },
          {
            'title': 'Flow H.E',
            'data': mqttProv.heatingUnitData?.flow1 ?? '0.0'
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
                                data: e['data']!,
                                minValue: 0.0,
                                maxValue: 30.0,
                                range1Value: 10.0,
                                range2Value: 20.0,
                                units: 'lpm',
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList()),
          graphPart: TankGraph(
            axisTitle: "Flow (lpm)",
            spline1Title: "Flow (To Solar Heater)",
            spline1DataSource:
                !_online ? flow1HistoryGraphData : mqttProv.flow2GraphData,
            spline2Title: "Flow (To Heat Exchanger)",
            spline2DataSource:
                !_online ? flow2HistoryGraphData : mqttProv.flow1GraphData,
            graphTitle: 'Graph of Flow Rate against Time',
          ),
          fromController: _fromDate,
          toController: _toDate,
          generateExcel: () async {
            setState(() {
              _isLoading = true;
            });
            List flowDataCombination = [];
            int i = 0;
            if (_online) {
              for (var data in mqttProv.flow1GraphData) {
                flowDataCombination.add({
                  keyMain: data.x,
                  key1: data.y,
                  key2: mqttProv.flow2GraphData[i].y,
                });
                i += 1;
              }
            } else {
              for (var data in flow1HistoryGraphData) {
                flowDataCombination.add({
                  keyMain: data.x,
                  key1: data.y,
                  key2: flow2HistoryGraphData[i].y,
                });
                i += 1;
              }
            }

            try {
              final fileBytes = await GenerateExcelFromList(
                listData: flowDataCombination,
                keyMain: keyMain,
                key1: key1,
                key2: key2,
              ).generateExcel();
              var directory = await getApplicationDocumentsDirectory();
              File(
                  ("${directory.path}/CBES/${HomeScreen.pageTitle(PageTitle.flowMeter)}/${DateFormat('EEE, MMM d yyyy  hh mm a').format(DateTime.now())}.xlsx"))
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
                    final flowMeterHistoricalData =
                        await HttpProtocol.queryFlowData(
                            fromDate: _fromDate.text, toDate: _toDate.text);
                    flow1HistoryGraphData.clear();
                    flow2HistoryGraphData.clear();

                    for (Map data in flowMeterHistoricalData) {
                      flow1HistoryGraphData.add(GraphAxis(
                          data.keys.toList()[0],
                          double.parse(
                              '${(data.values.toList()[0][HttpProtocol.flow1]).toString()}.0')));
                      flow2HistoryGraphData.add(GraphAxis(
                          data.keys.toList()[0],
                          double.parse(
                              '${(data.values.toList()[0][HttpProtocol.flow2]).toString()}.0')));
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
        );
      });
    });
  }
}
