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

class ThermalEnergyScreen extends StatefulWidget {
  const ThermalEnergyScreen({Key? key}) : super(key: key);

  @override
  State<ThermalEnergyScreen> createState() => _ThermalEnergyScreenState();
}

class _ThermalEnergyScreenState extends State<ThermalEnergyScreen> {
  var _online = true;
  final _fromDate = TextEditingController();
  final _toDate = TextEditingController();

  final List<GraphAxis> thermalEnergyHistoryGraphData = [];

  var _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _fromDate.dispose();
    _toDate.dispose();
  }

  static const keyMain = "Datetime";
  static const key1 = "Thermal Energy";

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
        // Compute MCDT, Compute Av.t,
        // todo here
        final List<Map<String, dynamic>> heatingUnitData = [
          {
            'title': 'Thermal Energy',
            'data': mqttProv.heatingUnitData!.enthalpy!.toStringAsFixed(1),
            'units': 'MJ',
            'minValue': 0.0,
            'maxValue': 500.0,
            'range1Value': 100.0,
            'range2Value': 350.0,
          },
          {
            'title': 'Average Temperature',
            'data': mqttProv.heatingUnitData!.averageTemp!.toStringAsFixed(1),
            'units': '°C',
            'minValue': 0.0,
            'maxValue': 100.0,
            'range1Value': 35.0,
            'range2Value': 55.0,
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
          graphPart: TankGraph(
            axisTitle: "Thermal Energy (MJ)",
            area1Title: "Thermal Energy (MJ)",
            area1DataSource: !_online
                ? thermalEnergyHistoryGraphData
                : mqttProv.enthalpyGraphData,
            graphTitle: 'Graph of Thermal Energy against Time',
          ),
          generateExcel: () async {
            setState(() {
              _isLoading = true;
            });
            List thermalDataCombination = [];
            if (_online) {
              for (var data in mqttProv.temperatureGraphData) {
                thermalDataCombination.add({
                  keyMain: data.x,
                  key1: data.y,
                });
              }
            } else {
              for (var data in thermalEnergyHistoryGraphData) {
                thermalDataCombination.add({
                  keyMain: data.x,
                  key1: data.y,
                });
              }
            }

            try {
              final fileBytes = await GenerateExcelFromList(
                listData: thermalDataCombination,
                keyMain: keyMain,
                key1: key1,
              ).generateExcel();
              var directory = await getApplicationDocumentsDirectory();
              File(
                  ("${directory.path}/CBES/${HomeScreen.pageTitle(PageTitle.thermalEnergyMeter)}/${DateFormat('EEE, MMM d yyyy  hh mm a').format(DateTime.now())}.xlsx"))
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
                  SearchToggleView.fromDateVal!
                      .isAfter(SearchToggleView.toDateVal!))
              ? null
              : () async {
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
                    final thermalEnergyHistoricalData =
                        await HttpProtocol.queryThermalEnergyData(
                            fromDate: _fromDate.text, toDate: _toDate.text);
                    thermalEnergyHistoryGraphData.clear();

                    for (Map data in thermalEnergyHistoricalData) {
                      thermalEnergyHistoryGraphData.add(GraphAxis(
                          data.keys.toList()[0], data.values.toList()[0]
                          // double.parse(
                          //     '${(data.values.toList()[0]).toString()}.0'),
                          ));
                    }
                    mqttProv.refresh();
                  } catch (e) {
                    print(e.toString());
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
