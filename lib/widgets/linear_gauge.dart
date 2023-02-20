import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../helpers/global_data.dart';

class LinearGauge extends StatelessWidget {
  const LinearGauge({
    Key? key,
    required this.title,
    required this.data,
    required this.gaugeWidth,
    required this.units,
    required this.min,
    required this.max,
  }) : super(key: key);
  final String title;
  final String data;
  final String units;
  final double gaugeWidth;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    final minRange = ((max - min) * 0.25) + min;
    final maxRange = ((max - min) * 0.55) + min;
    final value = double.parse(data);
    final color = value < minRange
        ? lowColor
        : value > minRange && value < maxRange
            ? mediumColor
            : highColor;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: SizedBox(
              width: gaugeWidth,
              child: SfLinearGauge(
                animationDuration: 5000,
                minimum: min,
                maximum: max,
                orientation: LinearGaugeOrientation.vertical,
                animateAxis: true,
                animateRange: true,
                showLabels: true,
                axisLabelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 10),
                axisTrackStyle: const LinearAxisTrackStyle(color: Colors.grey),
                majorTickStyle: LinearTickStyle(
                    color: Theme.of(context).colorScheme.primary),
                minorTickStyle: LinearTickStyle(
                    color: Theme.of(context).colorScheme.primary),
                useRangeColorForAxis: true,
                labelPosition: LinearLabelPosition.inside,
                interval: (max - min) / 5,
                markerPointers: [
                  LinearWidgetPointer(
                    value: value,
                    child: Container(
                      width: 20,
                      height: 15,
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: color),
                    ),
                  )
                ],
                barPointers: [
                  LinearBarPointer(
                    value: value,
                    color: color,
                  )
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4)),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              '${value.toStringAsFixed(1)} $units',
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
