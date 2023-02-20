import 'package:flutter/material.dart';

import '../widgets/dashboard_screen_gauge_view.dart';
import '../widgets/dashboard_screen_scada.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key, required this.switchDashboardPage})
      : super(key: key);
  final Function switchDashboardPage;
  static const temperatureConfig = {
    'units': '°C',
    'minValue': 0.0,
    'maxValue': 100.0,
    'range1Value': 25.0,
    'range2Value': 55.0
  };
  static const humidityConfig = {
    'units': '%',
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
    'units': 'KW',
    'minValue': 0.0,
    'maxValue': 100.0,
    'range1Value': 15.0,
    'range2Value': 65.0
  };
  static const irradianceConfig = {
    'units': 'w/m²',
    'minValue': 0.0,
    'maxValue': 2000.0,
    'range1Value': 400.0,
    'range2Value': 900.0
  };

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var _scadaView = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (builder, cons) => SizedBox(
              width: cons.maxWidth,
              height: cons.maxHeight,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _scadaView ? '3D View' : 'Gauge View',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 20.0,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        SizedBox(
                          width: cons.maxWidth * 0.01,
                        ),
                        Switch.adaptive(
                            activeColor: Theme.of(context).colorScheme.primary,
                            value: _scadaView,
                            onChanged: (val) {
                              setState(() {
                                _scadaView = val;
                              });
                            })
                      ],
                    ),
                  ),
                  if (_scadaView) DashboardScreenScada(cons: cons),
                  if (!_scadaView)
                    DashboardScreenGaugeView(
                        switchDashboardPage: widget.switchDashboardPage,
                        cons: cons),
                ],
              ),
            ));
  }
}
