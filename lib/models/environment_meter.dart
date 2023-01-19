class EnvironmentMeter {
  String? temperature;
  String? humidity;
  String? illuminance;
  bool? status;
  String? usage;

  EnvironmentMeter(
      {this.temperature,
      this.humidity,
      this.illuminance,
      this.status,
      this.usage});

  static EnvironmentMeter fromMap(Map<String, dynamic> environmentMeter) {
    String? temperatureValue;
    String? humidityValue;
    String? luxValue;
    for (Map element in (environmentMeter['feeds'] as List)) {
      if (element.containsKey("field1")) {
        temperatureValue = (element['field1'] as double).toStringAsFixed(1);
      }
      if (element.containsKey("field2")) {
        humidityValue = (element['field2'] as int).toStringAsFixed(1);
      }
      if (element.containsKey("field3")) {
        luxValue = (element['field3'] as double).toStringAsFixed(1);
      }
    }
    return EnvironmentMeter(
      temperature: temperatureValue,
      humidity: humidityValue,
      illuminance: luxValue,
    );
  }

  Map<String, dynamic> asMap() => {
        "temperature": temperature ?? '0.0',
        "humidity": humidity ?? '0.0',
        "lux": illuminance ?? '0.0',
      };
}
