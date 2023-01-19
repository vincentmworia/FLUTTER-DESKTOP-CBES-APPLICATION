import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mqtt.dart';
import '../widgets/IotPageTemplate.dart';
import '../widgets/radial_gauge_sf.dart';
import '../widgets/tank_graph.dart';

class DuctMeterScreen extends StatefulWidget {
  const DuctMeterScreen({Key? key}) : super(key: key);

  @override
  State<DuctMeterScreen> createState() => _DuctMeterScreenState();
}

class _DuctMeterScreenState extends State<DuctMeterScreen> {
  var _online = true;

  bool _onlineBnStatus(bool isOnline) {
    setState(() {
      _online = isOnline;
    });
    return isOnline;
  }
  static Map<String, double> range100Data = {
    'minValue': 0.0,
    'maxValue': 100.0,
    'range1Value': 25.0,
    'range2Value': 55.0
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      return Consumer<MqttProvider>(builder: (context, mqttProv, child) {

        final List<Map<String, dynamic>> environmentMeterData = [
          {
            'title': 'Temperature',
            'units': '°C',
            'data': mqttProv.environmentMeterData?.temperature ?? '0.0',
            ...range100Data
          },
          {
            'title': 'Humidity',
            'units': '%',
            'data': mqttProv.environmentMeterData?.humidity ?? '0.0',
            ...range100Data
          },
        ];
        return IotPageTemplate(
          onlineBnStatus: _onlineBnStatus,
          // gaugePart: Container(),
          gaugePart: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: environmentMeterData
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
                              child:
                              SyncfusionRadialGauge(
                                title: e['title'],
                                units: e['units'],
                                data: e['data'],
                                minValue: e['minValue'],
                                maxValue: e['maxValue'],
                                range1Value: e['range1Value'],
                                range2Value: e['range2Value'],
                              )
                              ,
                            ),
                          ),
                        ),
                      ))
                  .toList()),
          graphPart: TankGraph(
            axisTitle: "Temp (°C) and Humidity (%)",
            spline1Title: "Temperature",
            spline1DataSource:
            !_online ? []: mqttProv.temperatureGraphData,
            spline2Title: "Humidity",
            spline2DataSource:
            !_online ? []: mqttProv.humidityGraphData,
          ),
        );
      });
    });
  }
}
