import 'dart:io';

import 'package:cbesdesktop/models/graph_axis.dart';
import 'package:cbesdesktop/screens/home_screen.dart';
import 'package:cbesdesktop/widgets/generate_excel_from_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../helpers/custom_data.dart';
import '../widgets/IotPageTemplate.dart';
import '../widgets/linear_gauge.dart';
import '../widgets/tank_graph.dart';
import '../providers/mqtt.dart';
import '../widgets/search_toggle_view.dart';

class HeatingUnitScreen extends StatefulWidget {
  const HeatingUnitScreen({Key? key}) : super(key: key);

  @override
  State<HeatingUnitScreen> createState() => _HeatingUnitScreenState();
}

class _HeatingUnitScreenState extends State<HeatingUnitScreen> {
  var _online = true;

  bool _onlineBnStatus(bool isOnline) {
    setState(() {
      _online = isOnline;
    });
    return isOnline;
  }

  static const keyMain = "Datetime";
  static const key1 = "Tank 1 temperature";
  static const key2 = "Tank 2 temperature";
  static const key3 = "Tank 3 temperature";

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      return Consumer<MqttProvider>(builder: (context, mqttProv, child) {
        final List<Map<String, String>> heatingUnitData = [
          {'title': 'Tank 1', 'data': mqttProv.heatingUnitData?.tank1 ?? '0.0'},
          {'title': 'Tank 2', 'data': mqttProv.heatingUnitData?.tank2 ?? '0.0'},
          {'title': 'Tank 3', 'data': mqttProv.heatingUnitData?.tank3 ?? '0.0'},
        ];
        return IotPageTemplate(
          onlineBnStatus: _onlineBnStatus,
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
            spline1DataSource: !_online ? [
              // todo Get data from HTTP, get past data for temp1, temp2, temp3
            ] : mqttProv.temp1GraphData,
            spline1Title: "Tank 1",
            spline2DataSource: !_online ? [] : mqttProv.temp2GraphData,
            spline2Title: "Tank 2",
            spline3DataSource: !_online ? [] : mqttProv.temp3GraphData,
            spline3Title: "Tank 3",
          ),
          generateExcel: () async {
            List tempDataCombination = [];
            int i = 0;
            for (var data in mqttProv.temp1GraphData) {
              tempDataCombination.add({
                keyMain: data.x,
                key1: data.y,
                key2: mqttProv.temp2GraphData[i].y,
                key3: mqttProv.temp3GraphData[i].y
              });
              i += 1;
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
                  ("${directory.path}/CBES/${HomeScreen.pageTitle(PageTitle.solarHeaterMeter)}/${DateFormat('dd-MMM-yyyy HH-mm-ss').format(DateTime.now())}.xlsx"))
                ..createSync(recursive: true)
                ..writeAsBytesSync(fileBytes);
              Future.delayed(Duration.zero).then((value) async =>
                  await customDialog(
                      context, "Excel file generated successfully"));
            } catch (e) {
              await customDialog(context, "Error generating Excel file");
            }
          },
        );
      });
    });
  }
}