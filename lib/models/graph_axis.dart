class GraphAxis {
  final String x;
  final double y;

  GraphAxis(this.x, this.y);

  static GraphAxis fromMap(Map<String, dynamic> val) =>
      GraphAxis(val.keys.first, double.parse(val.values.first));

}
