import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../providers/mqtt.dart';
import '../models/graph_axis.dart';

class TankGraph extends StatelessWidget {
  const TankGraph({
    Key? key,
    required this.axisTitle,
    this.spline1Title,
    this.spline1DataSource,
    this.spline2Title,
    this.spline2DataSource,
    this.spline3Title,
    this.spline3DataSource,
    this.area1Title,
    this.area1DataSource,
    this.area2Title,
    this.area2DataSource,
    this.area3Title,
    this.area3DataSource,
  }) : super(key: key);
  final String axisTitle;
  final String? spline1Title;
  final List<GraphAxis>? spline1DataSource;
  final String? spline2Title;
  final List<GraphAxis>? spline2DataSource;
  final String? spline3Title;
  final List<GraphAxis>? spline3DataSource;
  final String? area1Title;
  final List<GraphAxis>? area1DataSource;
  final String? area2Title;
  final List<GraphAxis>? area2DataSource;
  final String? area3Title;
  final List<GraphAxis>? area3DataSource;

  static const graph1Color = Colors.red;
  static const graph2Color = Colors.blue;
  static const graph3Color = Colors.orange;
  static const opacity = 0.5;

  // TODO Graph filtration using HTTP requests
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Consumer<MqttProvider>(
        builder: (_, mqttProv, ___) => SfCartesianChart(
          // title: ChartTitle(text: 'Temperature for every 10 sec'),
          primaryXAxis: CategoryAxis(
              title: AxisTitle(text: "Time"), placeLabelsNearAxisLine: true),
          trackballBehavior: TrackballBehavior(
            activationMode: ActivationMode.singleTap,
            enable: true,
            lineColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
            tooltipAlignment: ChartAlignment.far,
            hideDelay: 10000, // shouldAlwaysShow: false,
          ),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            activationMode: ActivationMode.singleTap,
          ),
          plotAreaBackgroundImage:
              const AssetImage('images/graph_background.PNG'),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: axisTitle),
          ),
          legend: Legend(
              isVisible: true,
              orientation: LegendItemOrientation.horizontal,
              alignment: ChartAlignment.center,
              isResponsive: true,
              position: LegendPosition.bottom),
          series: <ChartSeries>[
            if (area1Title != null)
              // SplineSeries<GraphAxis, String>(
              SplineAreaSeries<GraphAxis, String>(
                name: area1Title,
                xAxisName: "Time (min)",
                yAxisName: area1Title,
                dataSource: area1DataSource ?? [],
                // color: Colors.white,
                color: graph1Color.withOpacity(opacity),
                xValueMapper: (GraphAxis data, _) => data.x,
                yValueMapper: (GraphAxis data, _) => data.y,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: false,
                  labelPosition: ChartDataLabelPosition.inside,
                ),
              ),
            if (area2Title != null)
              SplineAreaSeries<GraphAxis, String>(
                name: area2Title,
                xAxisName: "Time (min)",
                yAxisName: area2Title,
                dataSource: area2DataSource ?? [],
                color: graph2Color.withOpacity(opacity),
                xValueMapper: (GraphAxis data, _) => data.x,
                yValueMapper: (GraphAxis data, _) => data.y,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: false,
                  labelPosition: ChartDataLabelPosition.inside,
                ),
              ),
            if (area3Title != null)
              SplineSeries<GraphAxis, String>(
                name: area3Title,
                xAxisName: "Time (min)",
                yAxisName: area3Title,
                // todo Fetch appropriate data
                dataSource: area3DataSource ?? [],
                color: graph1Color.withOpacity(opacity),

                xValueMapper: (GraphAxis data, _) => data.x,
                yValueMapper: (GraphAxis data, _) => data.y,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: false,
                  labelPosition: ChartDataLabelPosition.inside,
                ),
              ),
            if (area1Title == null)
              SplineSeries<GraphAxis, String>(
                name: spline1Title,
                xAxisName: "Time (min)",
                yAxisName: spline1Title,
                dataSource: spline1DataSource ?? [],
                color: graph1Color,
                xValueMapper: (GraphAxis data, _) => data.x,
                yValueMapper: (GraphAxis data, _) => data.y,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: false,
                  labelPosition: ChartDataLabelPosition.inside,
                ),
              ),
            if (area1Title == null && spline2Title != null)
              SplineSeries<GraphAxis, String>(
                name: spline2Title,
                xAxisName: "Time (min)",
                yAxisName: spline2Title,
                dataSource: spline2DataSource ?? [],
                color: graph2Color,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: false,
                  labelPosition: ChartDataLabelPosition.inside,
                ),
                xValueMapper: (GraphAxis data, _) => data.x,
                yValueMapper: (GraphAxis data, _) => data.y,
              ),
            if (area1Title == null && spline3Title != null)
              SplineSeries<GraphAxis, String>(
                name: spline3Title,
                xAxisName: "Time (min)",
                yAxisName: spline3Title,
                dataSource: spline3DataSource ?? [],
                color: graph3Color,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: false,
                  labelPosition: ChartDataLabelPosition.inside,
                ),
                xValueMapper: (GraphAxis data, _) => data.x,
                yValueMapper: (GraphAxis data, _) => data.y,
              ),
          ],
        ),
      ),
    );
  }
}
