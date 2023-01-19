import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/IotPageTemplate.dart';
import '../widgets/linear_gauge.dart';
import '../widgets/tank_graph.dart';
import '../providers/mqtt.dart';
import '../widgets/toggle_online_view.dart';

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
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      return Consumer<MqttProvider>(builder: (context, mqttProv, child) {
        final List<Map<String, String>> heatingUnitData = [
          {'title': 'Tank 1', 'data': mqttProv.heatingUnitData?.tank1 ?? '0.0'},
          {'title': 'Tank 2', 'data': mqttProv.heatingUnitData?.tank2 ?? '0.0'},
          {'title': 'Tank 3', 'data': mqttProv.heatingUnitData?.tank3 ?? '0.0'},
        ];
        return IotPageTemplate(onlineBnStatus: _onlineBnStatus,gaugePart: Row(
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
                  title: e['title'],
                  data: e['data'],
                  gaugeWidth: cons.maxWidth * 0.075),
            ))
                .toList()),graphPart:  TankGraph(
          axisTitle: "Temp (°C)",
          spline1DataSource:
          !_online ? [] : mqttProv.temp1GraphData,
          spline1Title: "Tank 1",
          spline2DataSource:
          !_online ? [] : mqttProv.temp2GraphData,
          spline2Title: "Tank 2",
          spline3DataSource:
          !_online ? [] : mqttProv.temp3GraphData,
          spline3Title: "Tank 3",
        ),);
      });
    });
  }
}

// class HeatingUnitScreen extends StatefulWidget {
//   const HeatingUnitScreen({Key? key}) : super(key: key);
//
//   @override
//   State<HeatingUnitScreen> createState() => _HeatingUnitScreenState();
// }
//
// class _HeatingUnitScreenState extends State<HeatingUnitScreen> {
//   var _online = true;
//
//   bool _onlineBnStatus(bool isOnline) {
//     setState(() {
//       _online = isOnline;
//     });
//     return isOnline;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (_, cons) {
//       return Consumer<MqttProvider>(builder: (context, mqttProv, child) {
//         final List<Map<String, String>> heatingUnitData = [
//           {'title': 'Tank 1', 'data': mqttProv.heatingUnitData?.tank1 ?? '0.0'},
//           {'title': 'Tank 2', 'data': mqttProv.heatingUnitData?.tank2 ?? '0.0'},
//           {'title': 'Tank 3', 'data': mqttProv.heatingUnitData?.tank3 ?? '0.0'},
//         ];
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Container(
//               margin: EdgeInsets.symmetric(
//                 vertical: cons.maxHeight * 0.05,
//                 horizontal: cons.maxWidth * 0.005,
//               ),
//               width: cons.maxWidth * 0.4,
//               height: double.infinity,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   SizedBox(
//                     height: cons.maxHeight * 0.5,
//
//                     // todo Break the child into a widget
//                     child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: heatingUnitData
//                             .map((e) => Card(
//                                   elevation: 8,
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10)),
//                                   color: Colors.white.withOpacity(0.85),
//                                   shadowColor:
//                                       Theme.of(context).colorScheme.primary,
//                                   child: LinearGauge(
//                                       title: e['title'],
//                                       data: e['data'],
//                                       gaugeWidth: cons.maxWidth * 0.075),
//                                 ))
//                             .toList()),
//                   ),
//                   ToggleOnlineView(toggleOnlineStatus: _onlineBnStatus),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Column(
//                 children: [
//                   Expanded(
//                     // todo Break widget
//                     child: TankGraph(
//                       axisTitle: "Temp (°C)",
//                       spline1DataSource:
//                           !_online ? [] : mqttProv.temp1GraphData,
//                       spline1Title: "Tank 1",
//                       spline2DataSource:
//                           !_online ? [] : mqttProv.temp2GraphData,
//                       spline2Title: "Tank 2",
//                       spline3DataSource:
//                           !_online ? [] : mqttProv.temp3GraphData,
//                       spline3Title: "Tank 3",
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       });
//     });
//   }
// }
