class HeatingUnit {
  String? tank1;
  String? tank2;
  String? tank3;
  String? flow1;
  String? flow2;

  HeatingUnit({
    required this.tank1,
    required this.tank2,
    required this.tank3,
    required this.flow1,
    required this.flow2,
  });

  static HeatingUnit fromMap(Map<String, dynamic> heatingUnitData) =>
      HeatingUnit(
          tank1: heatingUnitData['TankT1'].toString(),
          tank2: heatingUnitData['TankT2'].toString(),
          tank3: heatingUnitData['TankT3'].toString(),
          flow1: heatingUnitData['Flow1'].toString(),
          flow2: heatingUnitData['Flow2'].toString());

  Map<String, String> asMap() => {
        "TankT1": tank1 ?? '0.0',
        "TankT2": tank2 ?? '0.0',
        "TankT3": tank3 ?? '0.0',
        "Flow1": flow1 ?? '0.0',
        "Flow2": flow2 ?? '0.0'
      };
}
