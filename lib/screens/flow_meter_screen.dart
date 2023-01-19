import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mqtt.dart';
import '../widgets/IotPageTemplate.dart';
import '../widgets/radial_gauge_sf.dart';
import '../widgets/tank_graph.dart';

class FlowMeterScreen extends StatefulWidget {
  const FlowMeterScreen({Key? key}) : super(key: key);

  @override
  State<FlowMeterScreen> createState() => _FlowMeterScreenState();
}

class _FlowMeterScreenState extends State<FlowMeterScreen> {
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
          onlineBnStatus: _onlineBnStatus,
          // gaugePart: Container(),
          gaugePart: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: heatingUnitData
                  .map((e) => Expanded(
                        child:Container(
                          margin: EdgeInsets.all(cons.maxWidth*0.02),
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
            !_online ? [] :mqttProv.flow2GraphData,
            spline2Title: "Flow (To Heat Exchanger)",
            spline2DataSource:
            !_online ? [] : mqttProv.flow1GraphData,
          ),
        );
      });
    });
  }
}

// static const flowTitle = 'Flow Rate';

// _parameterView(
//     context: context,
//     width: cons.maxWidth,
//     height: cons.maxHeight,
//     title: flowTitle,
//     valueParams: Consumer<MqttProvider>(
//       builder: (context, mqttProv, child) {
//         final List<Map<String, String>> heatingUnitData = [
//           {
//             'title': 'Flow S.H',
//             'data': mqttProv.heatingUnitData?.flow2 ?? '0.0'
//           },
//           {
//             'title': 'Flow H.E',
//             'data': mqttProv.heatingUnitData?.flow1 ?? '0.0'
//           },
//         ];
//
//         return Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: heatingUnitData
//                 .map((e) => Card(
//                       elevation: 8,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                       color: Colors.white.withOpacity(0.85),
//                       shadowColor:
//                           Theme.of(context).colorScheme.primary,
//                       child: SizedBox(
//                         width: 175,
//                         height: double.infinity,
//                         child: SyncfusionRadialGauge(
//                           title: e['title']!,
//                           data: e['data']!,
//                           minValue: 0.0,
//                           maxValue: 30.0,
//                           range1Value: 10.0,
//                           range2Value: 20.0,
//                           units: 'lpm',
//                         ),
//                       ),
//                     ))
//                 .toList());
//       },
//     ),
//     graphParams:
//     TankGraph(
//       axisTitle: "Flow (lpm)",
//       spline1Title: "Flow (To Solar Heater)",
//       spline1DataSource: mqttProv.flow2GraphData,
//       spline2Title: "Flow (To Heat Exchanger)",
//       spline2DataSource: mqttProv.flow1GraphData,
//     )
// ),
// graphParams:const TankGraph()),
