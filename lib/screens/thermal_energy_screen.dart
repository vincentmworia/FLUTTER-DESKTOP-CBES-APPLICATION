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

class ThermalEnergyScreen extends StatefulWidget {
  const ThermalEnergyScreen({Key? key}) : super(key: key);

  @override
  State<ThermalEnergyScreen> createState() => _ThermalEnergyScreenState();
}

class _ThermalEnergyScreenState extends State<ThermalEnergyScreen> {
  var _online = true;
  final _fromDate = TextEditingController();
  final _toDate = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _fromDate.dispose();
    _toDate.dispose();
  }

  static const keyMain = "Datetime";
  static const key1 = "";
  static const capacitance = 4132.0;
  static const tankTemp = 0.0;
  static const period = 2;

  // period of data being published from PLC
  // Later, take the timestamp from PLC

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
            'data': enthalpy.toStringAsFixed(1),
            'units': 'KJ',
            'minValue': 0.0,
            'maxValue': 500.0,
            'range1Value': 100.0,
            'range2Value': 350.0,
          },
          {
            'title': 'Average Temperature',
            'data': (averageTemp).toStringAsFixed(1),
            'units': '°C',
            'minValue': 0.0,
            'maxValue': 100.0,
            'range1Value': 35.0,
            'range2Value': 55.0,
          },
        ];
        return IotPageTemplate(
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
            axisTitle: "Flow (lpm)",
            spline1Title: "Flow (To Solar Heater)",
            spline1DataSource: !_online ? [] : mqttProv.flow2GraphData,
            spline2Title: "Flow (To Heat Exchanger)",
            spline2DataSource: !_online ? [] : mqttProv.flow1GraphData,
            graphTitle: 'Graph of Flow Rate against Time',
          ),
          generateExcel: () async {
            List tempDataCombination = [];
            for (var data in mqttProv.flow1GraphData) {
              tempDataCombination.add({
                keyMain: data.x,
                key1: data.y,
              });
            }

            try {
              final fileBytes = await GenerateExcelFromList(
                listData: tempDataCombination,
                keyMain: keyMain,
                key1: key1,
              ).generateExcel();
              var directory = await getApplicationDocumentsDirectory();
              File(
                  ("${directory.path}/CBES/${HomeScreen.pageTitle(PageTitle.flowMeter)}/${DateFormat('dd-MMM-yyyy HH-mm-ss').format(DateTime.now())}.xlsx"))
                ..createSync(recursive: true)
                ..writeAsBytesSync(fileBytes);
              Future.delayed(Duration.zero).then((value) async =>
                  await customDialog(
                      context, "Excel file generated successfully"));
            } catch (e) {
              await customDialog(context, "Error generating Excel file");
            }
          },
          fromController: _fromDate,
          toController: _toDate,
          searchDatabase: () {},
        );
      });
    });
  }
}
