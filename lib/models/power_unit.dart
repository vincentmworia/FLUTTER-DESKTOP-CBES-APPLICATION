class PowerUnit {
  bool? status;
  String? deviceMode;
  String? time;
  String? acVoltage;
  String? acFrequency;
  String? pvInputVoltage;
  String? pvInputPower;
  String? outputApparentPower;
  String? outputActivePower;
  String? batteryVoltage;
  String? batteryCapacity;
  String? chargingCurrent;
  String? batteryDischargeCurrent;
  String? outputVoltage;
  String? outputFrequency;

  PowerUnit({
    required this.status,
    required this.deviceMode,
    required this.time,
    required this.acVoltage,
    required this.acFrequency,
    required this.pvInputVoltage,
    required this.pvInputPower,
    required this.outputApparentPower,
    required this.outputActivePower,
    required this.batteryVoltage,
    required this.batteryCapacity,
    required this.chargingCurrent,
    required this.batteryDischargeCurrent,
    required this.outputVoltage,
    required this.outputFrequency,
  });

  static PowerUnit fromMap(Map<String, dynamic> powerUnitData) => PowerUnit(
        status: powerUnitData['status'].toString() == '1' ? true : false,
        deviceMode: powerUnitData['device_mode'].toString(),
        time: powerUnitData['time'],
        acVoltage: powerUnitData['ac_voltage'].toString(),
        acFrequency: powerUnitData['ac_frequency'].toString(),
        pvInputVoltage: powerUnitData['pv_input_voltage'].toString(),
        pvInputPower: powerUnitData['pv_input_power'].toString(),
        outputApparentPower: powerUnitData['output_apparent_power'].toString(),
        outputActivePower: powerUnitData['output_active_power'].toString(),
        batteryVoltage: powerUnitData['battery_voltage'].toString(),
        batteryCapacity: powerUnitData['battery_capacity'].toString(),
        chargingCurrent: powerUnitData['charging_current'].toString(),
        batteryDischargeCurrent:
            powerUnitData['battery_discharge_current'].toString(),
        outputVoltage: powerUnitData['output_voltage'].toString(),
        outputFrequency: powerUnitData['output_frequency'].toString(),
      );

  Map<String, dynamic> asMap() => {
        "status": status == true ? '1' : '0',
        "device_mode": deviceMode,
        "time": time,
        "ac_voltage": acVoltage,
        "ac_frequency": acFrequency,
        "pv_input_voltage": pvInputVoltage,
        "pv_input_power": pvInputPower,
        "output_apparent_power": outputActivePower,
        "output_active_power": outputActivePower,
        "battery_voltage": batteryVoltage,
        "battery_capacity": batteryCapacity,
        "charging_current": chargingCurrent,
        "battery_discharge_current": batteryDischargeCurrent,
        "output_voltage": outputVoltage,
        "output_frequency": outputFrequency,
      };
}
