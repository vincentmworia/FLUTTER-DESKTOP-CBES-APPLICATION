import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../helpers/global_data.dart';

class SyncfusionRadialGauge extends StatelessWidget {
  const SyncfusionRadialGauge(
      {Key? key,
      required this.title,
      required this.data,
      required this.minValue,
      required this.maxValue,
      required this.range1Value,
      required this.range2Value,
      required this.units})
      : super(key: key);
  final String title;
  final String units;
  final String data;
  final double minValue;
  final double maxValue;
  final double range1Value;
  final double range2Value;

  @override
  Widget build(BuildContext context) {
    final value = double.parse(data);
    final color = value < range1Value
        ? lowColor
        : value > range1Value && value < range2Value
            ? mediumColor
            : highColor;
    return SfRadialGauge(
      title: GaugeTitle(
        text: title ,
        // text: title.toUpperCase(),
        textStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold),
      ),
      animationDuration: 4000,
      enableLoadingAnimation: true,
      axes: <RadialAxis>[
        RadialAxis(
            minimum: minValue,
            maximum: maxValue,
            startAngle: 140,
            endAngle: 40,
            interval: maxValue/10,
            useRangeColorForAxis: true,
            axisLabelStyle:
                GaugeTextStyle(color: Theme.of(context).colorScheme.primary),
            labelOffset: 10,
            majorTickStyle:
                MajorTickStyle(color: Theme.of(context).colorScheme.primary),
            minorTicksPerInterval: 5,
            minorTickStyle: MinorTickStyle(
                color:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
            pointers: <GaugePointer>[
              MarkerPointer(
                value: value,
                color: color,
              ),
              RangePointer(
                color: color,
                value: value,
              ),
              NeedlePointer(
                  value: value,
                  needleStartWidth: 1,
                  needleEndWidth: 3,
                  needleColor: color),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                  widget: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      '$data\t$units',
                      // child: Text('$data °C',
                      style: TextStyle(
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                  ),
                  angle: 90,
                  positionFactor: 0.8)
            ]),
      ],
    );
  }
}
