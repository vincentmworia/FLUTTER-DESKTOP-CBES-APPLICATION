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

class ThermalEnergyScreen extends StatefulWidget {
  const ThermalEnergyScreen({Key? key}) : super(key: key);

  @override
  State<ThermalEnergyScreen> createState() => _ThermalEnergyScreenState();
}

class _ThermalEnergyScreenState extends State<ThermalEnergyScreen> {
  var _online = true;
  final _fromDate = TextEditingController();
  final _toDate = TextEditingController();

  final List<GraphAxis> waterThermalEnergyHistoryGraphData = [];
  final List<GraphAxis> pvThermalEnergyHistoryGraphData = [];

  var _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _fromDate.dispose();
    _toDate.dispose();
  }

  static const keyMain = "Datetime";
  static const key1 = "Water Thermal Energy (KJ)";
  static const key2 = "Pv Thermal Energy (KJ)";

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
          'units': 'KJ',
          'minValue': 0.0,
          'maxValue': 50.0,
          'range1Value': 15.0,
          'range2Value': 35.0
        };
        final List<Map<String, dynamic>> heatingUnitData = [
          {
            'title': 'Water Thermal Energy',
            'data':
                mqttProv.heatingUnitData?.waterEnthalpy!.toStringAsFixed(1) ??
                    '_._',
            ...gaugeConfig
          },
          {
            'title': 'Pv Thermal Energy',
            'data': mqttProv.heatingUnitData?.pvEnthalpy.toStringAsFixed(1) ??
                '_._',
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
                                data: e['data'] == '_._' ? '0.0' : e['data']!,
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
            axisTitle: "Thermal Energy (KJ)",
            area1Title: "Water Thermal Energy (KJ)",
            area1DataSource: !_online
                ? waterThermalEnergyHistoryGraphData
                : mqttProv.waterEnthalpyGraphData,
            area2Title: "Pv Thermal Energy (KJ)",
            area2DataSource: !_online
                ? pvThermalEnergyHistoryGraphData
                : mqttProv.pvEnthalpyGraphData,
            graphTitle: 'Graph of Thermal Energy against Time',
          ),
          generateExcel: () async {
            setState(() {
              _isLoading = true;
            });
            List thermalDataCombination = [];
            var i = 0;
            if (_online) {
              for (var data in mqttProv.waterEnthalpyGraphData) {
                thermalDataCombination.add({
                  keyMain: data.x,
                  key1: data.y,
                  key2: mqttProv.pvEnthalpyGraphData[i].y,
                });
              }
              i += 1;
            } else {
              for (var data in waterThermalEnergyHistoryGraphData) {
                thermalDataCombination.add({
                  keyMain: data.x,
                  key1: data.y,
                  key2: pvThermalEnergyHistoryGraphData[i].y,
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
                  ("${directory.path}/CBES/${HomeScreen.pageTitle(PageTitle.thermalEnergyMeter)}/${DateFormat(GenerateExcelFromList.excelFormat).format(DateTime.now())}.xlsx"))
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
              final thermalEnergyHistoricalData =
                  await HttpProtocol.queryThermalEnergyData(
                      fromDate: _fromDate.text, toDate: _toDate.text);
              waterThermalEnergyHistoryGraphData.clear();
              pvThermalEnergyHistoryGraphData.clear();

              for (Map data in thermalEnergyHistoricalData) {
                waterThermalEnergyHistoryGraphData.add(GraphAxis(
                    data.keys.toList()[0],
                    (data.values.toList()[0][HttpProtocol.waterThermal])
                    // double.parse(
                    //     '${(data.values.toList()[0][HttpProtocol.tank1]).toString()}.0')

                    ));
                pvThermalEnergyHistoryGraphData.add(GraphAxis(
                    data.keys.toList()[0],
                    (data.values.toList()[0][HttpProtocol.pvThermal])
                    // double.parse(
                    //     '${(data.values.toList()[0][HttpProtocol.tank1]).toString()}.0')
                    ));
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
              (!_online && waterThermalEnergyHistoryGraphData.isNotEmpty) ||
                  (_online && mqttProv.waterEnthalpyGraphData.isNotEmpty),
        );
      });
    });
  }
}
