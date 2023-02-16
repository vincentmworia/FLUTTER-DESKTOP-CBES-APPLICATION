import 'dart:math';

class HeatingUnit {
  String? tank1;
  String? tank2;
  String? tank3;
  String? flow1;
  String? flow2;
  static const capacitance = 4182.0;
  static const tankTemp = 25.0;
  static const density = 997.0;
  static const periodOfData = 2.0;

  // static const irradiance = 700;

  static const solarArea = 2.0;

  double get getIrradiance => Random().nextDouble() * (100) + 700;

  double? averageTemp;

  double? mass;

  double? get waterEnthalpy {
    if ((tank1 == null) ||
        (tank2 == null) ||
        (tank3 == null) ||
        (flow1 == null) ||
        (flow2 == null)) {
      return null;
    }

    mass = double.parse(flow1 ?? '0.0') * (1/60000) * periodOfData * density;
    // mass = double.parse(flow1 ?? '0.0') * 0.06 * periodOfData * density;
    averageTemp = (double.parse(tank1!) +

            // todo eliminated tank2 =>  double.parse(tank2!)
            0 +
            double.parse(tank3!)) /
        2;
    return ((mass! * capacitance * (averageTemp! - tankTemp)) / 1000);
  }


  double get pvEnthalpy =>( solarArea * 3 * getIrradiance *periodOfData)/1000;

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
