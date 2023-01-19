import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../helpers/global_data.dart';

class LinearGauge extends StatelessWidget {
  const LinearGauge({
    Key? key,
    required this.title,
    required this.data,
    required this.gaugeWidth,
  }) : super(key: key);
  final String? title;
  final String? data;
  final double? gaugeWidth;

  @override
  Widget build(BuildContext context) {
    final value = double.parse(data ?? '0.0');
    final color = value < 25
        ? lowColor
        : value > 25 && value < 55
            ? mediumColor
            : highColor;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            title == null ? '' : title!/*.toUpperCase()*/,
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: SizedBox(
              width: gaugeWidth,
              child: SfLinearGauge(
                animationDuration: 1000,
                minimum: 0,
                maximum: 100,
                orientation: LinearGaugeOrientation.vertical,
                animateAxis: true,
                animateRange: true,
                showLabels: true,
                axisLabelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 10),
                axisTrackStyle: const LinearAxisTrackStyle(color: Colors.grey),
                // todo Tick styles
                majorTickStyle: LinearTickStyle(
                    color: Theme.of(context).colorScheme.primary),
                minorTickStyle: LinearTickStyle(
                    color: Theme.of(context).colorScheme.primary),
                useRangeColorForAxis: true,
                labelPosition: LinearLabelPosition.inside,
                interval: 20,
                markerPointers: [
                  LinearWidgetPointer(
                    value: value,
                    child: Container(
                      width: 50,
                      height: 13,
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
              '${value.toStringAsFixed(1)} °C',
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
