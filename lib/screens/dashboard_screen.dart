import 'package:cbesdesktop/providers/mqtt.dart';
import 'package:cbesdesktop/widgets/linear_gauge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/radial_gauge_kd.dart';
import '../widgets/radial_gauge_sf.dart';
import './home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key, required this.switchDashboardPage})
      : super(key: key);
  final Function switchDashboardPage;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var _threeDView = false;
  static const temperatureHumidityConfig = {
    'units': '°C',
    'minValue': 0.0,
    'maxValue': 100.0,
    'range1Value': 25.0,
    'range2Value': 55.0
  };
  static const flowConfig = {
    'units': 'lpm',
    'minValue': 0.0,
    'maxValue': 40.0,
    'range1Value': 15.0,
    'range2Value': 25.0
  };
  static const powerConfig = {
    'units': 'Kwh',
    'minValue': 0.0,
    'maxValue': 1000.0,
    'range1Value': 250.0,
    'range2Value': 750.0
  };
  static const irradianceConfig = {
    'units': 'w/m²',
    'minValue': 0.0,
    'maxValue': 1000.0,
    'range1Value': 250.0,
    'range2Value': 750.0
  };

  final bdRadius = BorderRadius.circular(10);

  Widget cardView(String title, Widget? child, BoxConstraints cons) =>
      GestureDetector(
        onDoubleTap: () {
          if (title == HomeScreen.pageTitle(PageTitle.solarHeaterMeter)) {
            widget.switchDashboardPage(PageTitle.solarHeaterMeter,
                HomeScreen.pageTitle(PageTitle.solarHeaterMeter));
          }
          if (title == HomeScreen.pageTitle(PageTitle.ambientMeter)) {
            widget.switchDashboardPage(PageTitle.ambientMeter,
                HomeScreen.pageTitle(PageTitle.ambientMeter));
          }
          if (title == HomeScreen.pageTitle(PageTitle.flowMeter)) {
            widget.switchDashboardPage(
                PageTitle.flowMeter, HomeScreen.pageTitle(PageTitle.flowMeter));
          }
          if (title == HomeScreen.pageTitle(PageTitle.electricalEnergyMeter)) {
            widget.switchDashboardPage(PageTitle.electricalEnergyMeter,
                HomeScreen.pageTitle(PageTitle.electricalEnergyMeter));
          }
          if (title == HomeScreen.pageTitle(PageTitle.ductMeter)) {
            widget.switchDashboardPage(
                PageTitle.ductMeter, HomeScreen.pageTitle(PageTitle.ductMeter));
          }
          if (title == HomeScreen.pageTitle(PageTitle.shedMeter)) {
            widget.switchDashboardPage(
                PageTitle.shedMeter, HomeScreen.pageTitle(PageTitle.shedMeter));
          }
        },
        child: Card(
          elevation: 8,
          shadowColor: Theme.of(context).colorScheme.primary,
          color: Colors.white.withOpacity(0.65),
          shape: RoundedRectangleBorder(borderRadius: bdRadius),
          child: SizedBox(
            width: cons.maxWidth * 0.275,
            height: cons.maxHeight * 0.4,
            child: Column(
              children: [
                Container(
                  width: cons.maxWidth * 0.15,
                  height: cons.maxHeight * 0.05,
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: bdRadius),
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                          fontSize: 18.0,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                Expanded(child: child ?? Container()),
              ],
            ),
          ),
        ),
      );

  Widget _gaugeView(List listData, double width) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: listData
          .map(
            (e) => Expanded(
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: e['title'].toString().contains('Tank')
                  ? LinearGauge(
                      title: e['title'],
                      data: e['data'],
                      gaugeWidth: width * 0.1,
                    )
                  // KdRadialGauge(
                  //   title: e['title'],
                  //   data: e['data'],
                  //   gaugeHeight: height * 0.15,
                  //   units: e['units'],
                  //   minValue: e['minValue'],
                  //   maxValue: e['maxValue'],
                  //   range1Value: e['range1Value'],
                  //   range2Value: e['range2Value'],
                  // )
                  : SyncfusionRadialGauge(
                      title: e['title'],
                      units: e['units'],
                      data: e['data'],
                      minValue: e['minValue'],
                      maxValue: e['maxValue'],
                      range1Value: e['range1Value'],
                      range2Value: e['range2Value'],
                    ),
            )),
          )
          .toList());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (builder, cons) {
      return SizedBox(
        width: cons.maxWidth,
        height: cons.maxHeight,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Switch.adaptive(
                    value: _threeDView,
                    onChanged: (val) {
                      setState(() {
                        _threeDView = val;
                      });
                    })
              ],
            ),
            if (_threeDView)
              const Expanded(
                  child: Center(
                child: Text("3D VIEW"),
              )),
            if (!_threeDView)
              Expanded(
                child: Consumer<MqttProvider>(
                  builder: (context, mqttProv, child) => Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            cardView(
                                HomeScreen.pageTitle(
                                    PageTitle.solarHeaterMeter),
                                _gaugeView([
                                  {
                                    'data': mqttProv.heatingUnitData?.tank1 ??
                                        '0.0',
                                    'title': 'Tank 1',
                                    ...temperatureHumidityConfig
                                  },
                                  {
                                    'data': mqttProv.heatingUnitData?.tank2 ??
                                        '0.0',
                                    'title': 'Tank 2',
                                    ...temperatureHumidityConfig
                                  },
                                  {
                                    'data': mqttProv.heatingUnitData?.tank3 ??
                                        '0.0',
                                    'title': 'Tank 3',
                                    ...temperatureHumidityConfig
                                  },
                                ], cons.maxWidth),
                                cons),
                            cardView(
                                HomeScreen.pageTitle(PageTitle.flowMeter),
                                _gaugeView([
                                  {
                                    'data': mqttProv.heatingUnitData?.flow1 ??
                                        '0.0',
                                    'title': 'Flow (S.H)',
                                    ...flowConfig
                                  },
                                  {
                                    'data': mqttProv.heatingUnitData?.flow2 ??
                                        '0.0',
                                    'title': 'Flow (H.E)',
                                    ...flowConfig
                                  },
                                ],cons.maxWidth),
                                cons),
                            cardView(
                                HomeScreen.pageTitle(
                                    PageTitle.electricalEnergyMeter),
                                _gaugeView([
                                  {
                                    'data': '0.0',
                                    'title': 'Pv Power',
                                    ...powerConfig
                                  },
                                  {
                                    'data': '0.0',
                                    'title': 'Output Power',
                                    ...powerConfig
                                  },
                                ], cons.maxWidth),
                                cons),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            cardView(
                                HomeScreen.pageTitle(PageTitle.ductMeter),
                                _gaugeView([
                                  {
                                    'data':
                                        mqttProv.ductMeterData?.temperature ??
                                            '0.0',
                                    'title': 'Temperature',
                                    ...temperatureHumidityConfig
                                  },
                                  {
                                    'data': mqttProv.ductMeterData?.humidity ??
                                        '0.0',
                                    'title': 'Humidity',
                                    ...temperatureHumidityConfig
                                  },
                                ],  cons.maxWidth),
                                cons),
                            cardView(
                                HomeScreen.pageTitle(PageTitle.shedMeter),
                                _gaugeView([
                                  {
                                    'data': '0.0',
                                    'title': 'Temperature',
                                    ...temperatureHumidityConfig
                                  },
                                  {
                                    'data': '0.0',
                                    'title': 'Humidity',
                                    ...temperatureHumidityConfig
                                  },
                                ], cons.maxWidth),
                                cons),
                            cardView(
                                HomeScreen.pageTitle(
                                    PageTitle.ambientMeter),
                                _gaugeView([
                                  {
                                    'data': '0.0',
                                    'title': 'Temperature',
                                    ...temperatureHumidityConfig
                                  },
                                  {
                                    'data': '0.0',
                                    'title': 'Irradiance',
                                    ...irradianceConfig
                                  },
                                ], cons.maxWidth),
                                cons),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
