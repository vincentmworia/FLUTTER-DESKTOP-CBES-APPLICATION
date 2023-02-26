import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/global_data.dart';
import '../providers/mqtt.dart';

class DashboardScreenScada extends StatelessWidget {
  const DashboardScreenScada({Key? key, required this.cons}) : super(key: key);
  final BoxConstraints cons;

  Widget _solarPanel(
          {required double width,
          required double height,
          required String temperature}) =>
      Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.asset(
            'images/SCADA/solar_heater2.jpg',
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              SizedBox(
                height: height * 0.015,
              ),
              Container(
                width: width * 0.07,
                height: height * 0.045,
                margin: EdgeInsets.only(left: width * 0.01),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: FittedBox(child: customTempText(temperature)),
                ),
              ),
            ],
          )
        ],
      );

  Widget customTempText(String temp) => FittedBox(
    child: Text('$temp °C',
        style: double.tryParse(temp) == null
            ? null
            : TextStyle(
                color: double.parse(temp) < 25
                    ? lowColor
                    : double.parse(temp) > 25 && double.parse(temp) < 55
                        ? mediumColor
                        : highColor)),
  );

  Widget customFlowWidget(
          {required String temp,
          required double width,
          required double height}) =>
      Card(
        elevation: 10,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SizedBox(
          width: width * 0.035,
          height: height * 0.03,
          child: FittedBox(
            child: Text(
              '$temp lpm',
              style: double.tryParse(temp) == null
                  ? null
                  : TextStyle(
                      color: double.parse(temp) < 15
                          ? lowColor
                          : double.parse(temp) > 15 && double.parse(temp) < 25
                              ? mediumColor
                              : highColor),
            ),
          ),
        ),
      );

  Widget customHumidityText(String humidity) => Text('$humidity %',
      style: double.tryParse(humidity) == null
          ? null
          : TextStyle(
              color: double.parse(humidity) < 25
                  ? lowColor
                  : double.parse(humidity) > 25 && double.parse(humidity) < 55
                      ? mediumColor
                      : highColor));

  Widget customLuxText(String lux) => Text(
        '$lux w/m²',
        style: double.tryParse(lux) == null
            ? null
            : TextStyle(
                color: double.parse(lux) < 400
                    ? lowColor
                    : double.parse(lux) > 400 && double.parse(lux) < 900
                        ? mediumColor
                        : highColor),
      );

  // static var systemOn = false;

  bool systemOn(MqttProvider mqttProv) {
    if (mqttProv.heatingUnitData == null ||
        mqttProv.heatingUnitData!.flow1 == null ||
        double.tryParse(mqttProv.heatingUnitData!.flow1!) == null ||
        double.parse(mqttProv.heatingUnitData!.flow1!) < 3) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final mqttProv = Provider.of<MqttProvider>(context);
    final width = cons.maxWidth;
    final height = cons.maxHeight;
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: width * 0.0075,
                    height: height * 0.65,
                    color: Colors.blue.withOpacity(systemOn(mqttProv) ? 1 : 0.25),
                  ),
                  Positioned(
                    bottom: height * 0.325,
                    left: width * 0.08,
                    child: Container(
                      width: width * 0.75,
                      height: height * 0.0175,
                      color: Colors.blue.withOpacity(systemOn(mqttProv) ? 1 : 0.25),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                          height: height * 0.3,
                          width: width * 0.1,
                          child: Image.asset(
                            'images/SCADA/water_tank.jpg',
                            fit: BoxFit.cover,
                          )),
                      // Spacer(),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: width * 0.09,
                                child: Image.asset(
                                  'images/SCADA/pump.jpg',
                                  fit: BoxFit.cover,
                                )),
                            Container(
                              width: width * 0.04,
                              height: height * 0.04,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      systemOn(mqttProv) ? Colors.green : Colors.red
                                  // color: Colors.red,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      // Spacer(),
                    ],
                  ),
                  Positioned(
                    top: height * 0.02,
                    left: width * 0.09,
                    child: Container(
                      width: width * 0.5,
                      height: height * 0.0175,
                      color: Colors.blue.withOpacity(systemOn(mqttProv) ? 1 : 0.25),
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                              height: height * 0.3,
                              child: Image.asset(
                                'images/SCADA/heat_exchanger.jpg',
                                fit: BoxFit.cover,
                              )),
                        ],
                      ),
                      Expanded(
                        child: SizedBox(
                          width: width * 0.5,
                          child: FittedBox(
                            child: Row(
                              children: [
                                _solarPanel(
                                    width: width,
                                    height: height,
                                    temperature:
                                        mqttProv.heatingUnitData?.tank1 ?? '_._'),
                                _solarPanel(
                                    width: width,
                                    height: height,
                                    temperature:
                                        mqttProv.heatingUnitData?.tank2 ?? '_._'),
                                _solarPanel(
                                    width: width,
                                    height: height,
                                    temperature:
                                        mqttProv.heatingUnitData?.tank3 ?? '_._'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: height * 0.225,
                    left: width * 0.2975,
                    child: Container(
                      width: width * 0.0075,
                      height: height * 0.2,
                      color: Colors.blue.withOpacity(systemOn(mqttProv) ? 1 : 0.25),
                    ),
                  ), 
                  Positioned(
                    top: height * 0.3,
                    left: width * 0.3,
                    child: customFlowWidget(
                        width: width,
                        height: height,
                        temp: mqttProv.heatingUnitData?.flow1 ?? '_._'),
                  ),
                  Positioned(
                    bottom: height * 0.325,
                    left: 0,
                    child: Container(
                      width: width * 0.04,
                      height: height * 0.0175,
                      color: Colors.blue.withOpacity(systemOn(mqttProv) ? 1 : 0.25),
                    ),
                  ),
                  // todo add Ubibot visualization
                  Positioned(
                    top: height * 0.02,
                    left: 0,
                    child: Container(
                      width: width * 0.2025,
                      height: height * 0.0175,
                      decoration: BoxDecoration(
                          color: Colors.blue
                              .withOpacity(systemOn(mqttProv) ? 1 : 0.25),
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20))),
                    ),
                  ),
                  Positioned(
                    top: height * 0.03,
                    left: width * 0.195,
                    child: Container(
                      width: width * 0.0075,
                      height: height * 0.02,
                      color: Colors.blue.withOpacity(systemOn(mqttProv) ? 1 : 0.25),
                    ),
                  ),
                  Positioned(
                    bottom: height * 0.325,
                    left: 0,
                    child: customFlowWidget(
                        width: width,
                        height: height,
                        temp: mqttProv.heatingUnitData?.flow2 ?? '_._'),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    width: width * 0.35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: width * 0.03,
                              child: Image.asset(
                                'images/SCADA/temp.png',
                              ),
                            ),
                            customTempText(mqttProv.heatingUnitData?.ambientTemp
                                    .toStringAsFixed(1) ??
                                '_._'),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: width * 0.025,
                              child: Image.asset(
                                'images/SCADA/humidity.png',
                              ),
                            ),
                            customHumidityText(mqttProv
                                    .heatingUnitData?.ambientHumidity
                                    .toStringAsFixed(1) ??
                                '_._'),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: width * 0.03,
                              child: Image.asset(
                                'images/SCADA/irradiance.png',
                              ),
                            ),
                            customLuxText(mqttProv
                                    .heatingUnitData?.ambientIrradiance
                                    .toStringAsFixed(1) ??
                                '_._'),
                          ],
                        ),
                        Expanded(
                          child: Image.asset(
                            'images/SCADA/sun.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: width * 0.35,
                          child: Image.asset(
                            'images/SCADA/greenhouse.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          top: height * 0.15,
                          child: Card(
                            elevation: 20,
                            shadowColor: Theme.of(context).colorScheme.primary,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: SizedBox(
                              width: width * 0.1,
                              height: height * 0.1,
                              child: FittedBox(
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: width * 0.03,
                                          child: Image.asset(
                                            'images/SCADA/temp.png',
                                          ),
                                        ),
                                        customTempText(
                                            mqttProv.shedMeterData?.temperature ??
                                                '_._'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: width * 0.025,
                                          child: Image.asset(
                                            'images/SCADA/humidity.png',
                                          ),
                                        ),
                                        customHumidityText(
                                            mqttProv.shedMeterData?.humidity ??
                                                '_._'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // todo Use Icons instead
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),


          Positioned(
            top: height*0.075,

            child: Card(
              elevation: 20,
              shadowColor: Theme.of(context).colorScheme.primary,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: SizedBox(
                width: width * 0.1,
                height: height * 0.1,
                child: FittedBox(
                  child: Row(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: width * 0.03,
                            child: Image.asset(
                              'images/SCADA/temp.png',
                            ),
                          ),
                          customTempText(
                              mqttProv.ductMeterData?.temperature ?? '_._'),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: width * 0.025,
                            child: Image.asset(
                              'images/SCADA/humidity.png',
                            ),
                          ),
                          customHumidityText(
                              mqttProv.ductMeterData?.humidity ?? '_._'),
                        ],
                      ),
                    ],
                  ),
                ),
                // todo Use Icons instead
              ),
            ),
          )
        ],
      ),
    );
  }
}
