class DuctMeter {
  String? temperature;
  String? humidity;

  DuctMeter({this.temperature, this.humidity});

  static DuctMeter fromMap(Map<String, dynamic> environmentMeter) {
    String? temperatureValue;
    String? humidityValue;
    for (Map element in (environmentMeter['feeds'] as List)) {
      if (element.containsKey("field1")) {
        temperatureValue = (element['field1'] as double).toStringAsFixed(1);
      }
      if (element.containsKey("field2")) {
        humidityValue = (element['field2'] as int).toStringAsFixed(1);
      }
    }
    return DuctMeter(
      temperature: temperatureValue,
      humidity: humidityValue,
    );
  }

  Map<String, dynamic> asMap() => {
        "temperature": temperature ?? '0.0',
        "humidity": humidity ?? '0.0',
      };
}
