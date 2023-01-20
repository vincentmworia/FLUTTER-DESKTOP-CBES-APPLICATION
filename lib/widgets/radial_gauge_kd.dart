import 'package:flutter/material.dart';
import 'package:kdgaugeview/kdgaugeview.dart';

import '../helpers/global_data.dart';

class KdRadialGauge extends StatefulWidget {
  const KdRadialGauge(
      {Key? key,
      required this.title,
      required this.data,
      required this.gaugeHeight,
      required this.units,
      required this.minValue,
      required this.maxValue, required this.range1Value, required this.range2Value})
      : super(key: key);
  final String? title;
  final double? gaugeHeight;
  final String? data;
  final String units;
  final double minValue;
  final double range1Value;
  final double range2Value;

  final double maxValue;

  @override
  State<KdRadialGauge> createState() => _KdRadialGaugeState();
}

class _KdRadialGaugeState extends State<KdRadialGauge> {
  var opacity = 0.0;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<KdGaugeViewState> key = GlobalKey<KdGaugeViewState>();
    final value = double.parse(widget.data ?? '0.0');
    Future.delayed(const Duration(seconds: 1)).then((value) {
      if (mounted) {
        setState(() => opacity = 1);
      }
    });
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(seconds: 1),
      child: SizedBox(
        height: widget.gaugeHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                widget.title == null ? '' : widget.title! /*.toUpperCase()*/,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: KdGaugeView(
                key: key,
                minSpeed: widget.minValue,
                maxSpeed: widget.maxValue,
                speed: value,
                // animate: true,
                duration: const Duration(seconds: 1),
                unitOfMeasurement: widget.units,
                unitOfMeasurementTextStyle: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                speedTextStyle: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                gaugeWidth: 5,
                minMaxTextStyle: const TextStyle(fontSize: 0),
                innerCirclePadding: 5,
                // inactiveGaugeColor: Colors.red,
                // subDivisionCircleColors: Theme.of(context).colorScheme.primary,
                // divisionCircleColors:Theme.of(context).colorScheme.primary,
                // activeGaugeColor: Colors.black,
                // baseGaugeColor: Colors.white,
                fractionDigits: 1,

                alertColorArray: const [lowColor, mediumColor, highColor],
                alertSpeedArray: const [0, range1Value, range2Value],
              ),
            ),
          ],
        ),
        // child: MyRadialGauge(title: 'Flow 1', data: '30'),
      ),
    );
  }
}
