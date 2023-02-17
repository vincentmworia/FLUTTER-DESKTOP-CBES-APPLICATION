class ShedMeter {
  String temperature;
  String humidity;

  ShedMeter({
    required this.temperature,
    required this.humidity,
  });

  static ShedMeter fromMap(Map<String, dynamic> shedMeterData) => ShedMeter(
        temperature: shedMeterData['temperature'].toString(),
        humidity: shedMeterData['humidity'].toString(),
      );

  Map<String, String> asMap() => {
        "temperature": temperature,
        "humidity": humidity,
      };
}
