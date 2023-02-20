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

class ElectricalEnergyScreen extends StatefulWidget {
  const ElectricalEnergyScreen({Key? key}) : super(key: key);

  @override
  State<ElectricalEnergyScreen> createState() => _ElectricalEnergyScreenState();
}

class _ElectricalEnergyScreenState extends State<ElectricalEnergyScreen> {
  var _online = true;
  final _fromDate = TextEditingController();
  final _toDate = TextEditingController();

  final List<GraphAxis> outputElectricalEnergyHistoryGraphData = [];
  final List<GraphAxis> pvElectricalEnergyHistoryGraphData = [];

  var _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _fromDate.dispose();
    _toDate.dispose();
  }

  static const keyMain = "Datetime";
  static const metrics = 'KW';
  static const key1 = "Output Electrical Energy ($metrics)";
  static const key2 = "Pv Electrical Energy ($metrics)";

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
        const gaugeConfig = {
          'units': metrics,
          'minValue': 0.0,
          'maxValue': 100.0,
          'range1Value': 15.0,
          'range2Value': 65.0
        };
        final List<Map<String, dynamic>> heatingUnitData = [
          {
            'title': 'Output Electrical Energy',
            'data': mqttProv.electricalEnergyData?.outputEnergy ?? '_._',
            ...gaugeConfig
          },
          {
            'title': 'Pv Electrical Energy',
            'data': mqttProv.electricalEnergyData?.pvEnergy ??'_._',
            ...gaugeConfig
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
                                minValue: e['minValue'],
                                maxValue: e['maxValue'],
                                range1Value: e['range1Value'],
                                range2Value: e['range2Value'],
                                units: e['units']!,
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList()),
          graphPart: MworiaGraph(
            axisTitle: "Electrical Energy $metrics",
            area1Title: key1,
            area1DataSource: !_online
                ? outputElectricalEnergyHistoryGraphData
                : mqttProv.outputElectricalEnergyGraphData,
            area2Title: key2,
            area2DataSource: !_online
                ? pvElectricalEnergyHistoryGraphData
                : mqttProv.pvElectricalEnergyGraphData,
            graphTitle: 'Graph of Electrical Energy against Time',
          ),
          generateExcel: () async {
            setState(() {
              _isLoading = true;
            });

            List thermalDataCombination = [];
            var i = 0;
            if (_online) {
              for (var data in mqttProv.outputElectricalEnergyGraphData) {
                thermalDataCombination.add({
                  keyMain: data.x,
                  key1: data.y,
                  key2: mqttProv.pvElectricalEnergyGraphData[i].y,
                });
              }
              i += 1;
            } else {
              for (var data in outputElectricalEnergyHistoryGraphData) {
                thermalDataCombination.add({
                  keyMain: data.x,
                  key1: data.y,
                  key2: pvElectricalEnergyHistoryGraphData[i].y,
                });
                i += 1;
              }
            }

            try {
              final fileBytes = await GenerateExcelFromList(
                listData: thermalDataCombination,
                keyMain: keyMain,
                key1: key1,
                key2: key2,
              ).generateExcel();
              var directory = await getApplicationDocumentsDirectory();
              File(
                  ("${directory.path}/CBES/${HomeScreen.pageTitle(PageTitle.electricalEnergyMeter)}/${DateFormat(GenerateExcelFromList.excelFormat).format(DateTime.now())}.xlsx"))
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
              final electricalEnergyHistoricalData =
                  await HttpProtocol.queryElectricalEnergyData(
                      fromDate: _fromDate.text, toDate: _toDate.text);
              outputElectricalEnergyHistoryGraphData.clear();
              pvElectricalEnergyHistoryGraphData.clear();

              for (Map data in electricalEnergyHistoricalData) {
                outputElectricalEnergyHistoryGraphData.add(GraphAxis(
                    data.keys.toList()[0],
                    (data.values.toList()[0]
                        [HttpProtocol.outputElectricalEnergy])));
                pvElectricalEnergyHistoryGraphData.add(GraphAxis(
                    data.keys.toList()[0],
                    (data.values.toList()[0]
                        [HttpProtocol.pvElectricalEnergy])));
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
          activateExcel: (!_online &&
                  outputElectricalEnergyHistoryGraphData.isNotEmpty) ||
              (_online && mqttProv.outputElectricalEnergyGraphData.isNotEmpty),
        );
      });
    });
  }
}
