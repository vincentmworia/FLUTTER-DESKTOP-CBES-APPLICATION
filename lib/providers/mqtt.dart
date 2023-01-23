import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../models/duct_meter.dart';
import '../models/graph_axis.dart';
import '../models/heating_unit.dart';
import '../models/power_unit.dart';
import '../private_data.dart';
import './login_user_data.dart';

enum ConnectionStatus {
  disconnected,
  connected,
}

// todo subscribe to all mqtt channels
class MqttProvider with ChangeNotifier {
  late MqttServerClient _mqttClient;
  Timer? timerGraph;
  Timer? timerDummyData;

  MqttServerClient get mqttClient => _mqttClient;

  String? get disconnectTopic => _devicesClient;

  String get disconnectMessage => "Disconnected-$_loginTime";

  HeatingUnit? get heatingUnitData => _heatingUnitData;
  HeatingUnit? _heatingUnitData;

  DuctMeter? get ductMeterData => _environmentMeterData;
  DuctMeter? _environmentMeterData;

  PowerUnit? get powerUnitData => _powerUnitData;
  PowerUnit? _powerUnitData;

  final List<GraphAxis> temp1GraphData = [];
  final List<GraphAxis> temp2GraphData = [];
  final List<GraphAxis> temp3GraphData = [];
  final List<GraphAxis> flow1GraphData = [];
  final List<GraphAxis> flow2GraphData = [];

  final List<GraphAxis> temperatureGraphData = [];
  final List<GraphAxis> humidityGraphData = [];

  // final List<GraphAxis> outputActivePowerGraphData = [];
  // final List<GraphAxis> pvPowerGraphData = [];

  // final List<GraphAxis> outputVoltageGraphData = [];

  var _connStatus = ConnectionStatus.disconnected;

  ConnectionStatus get connectionStatus => _connStatus;

  // todo set unique Id for individual devices? From Email?

  static final platform = Platform.isAndroid
      ? "Android"
      : Platform.isWindows
          ? "Windows"
          : Platform.isFuchsia
              ? "Fuchsia"
              : Platform.isIOS
                  ? "IOS"
                  : Platform.isLinux
                      ? "Linux"
                      : "Unknown Operating System";

  //
  // static final String deviceId =
  //     '&${ LoginUserData.getLoggedUser!.email}&${ LoginUserData.getLoggedUser!.firstname}&${ LoginUserData.getLoggedUser!.lastname}';

  // static final String _devicesClient = 'cbes/dekut/devices/$platform/${json.encode(LoginUserData.getLoggedUser?.asMqttMap())}';

  String? _deviceId;
  String? _devicesClient;
  String? _loginTime;

  // todo If disconnected, nullify the token and forcefully logout the user

  // todo Add the date in the format over here
  String _duration(DateTime time) => DateFormat('HH:mm:ss')
      .format(time /*time.subtract(Duration(minutes: delay))*/);

  // DateFormat('dd-MMM-yyyy HH:mm:ss').format( time/*time.subtract(Duration(minutes: delay))*/ );

  Future<ConnectionStatus> initializeMqttClient() async {
    _deviceId =
        '&${LoginUserData.getLoggedUser!.email}&${LoginUserData.getLoggedUser!.firstname}&${LoginUserData.getLoggedUser!.lastname}';
    _devicesClient = 'cbes/dekut/devices/$platform/$_deviceId';

    _loginTime = DateTime.now().toIso8601String();
    final connMessage = MqttConnectMessage()
      ..authenticateAs(mqttUsername, mqttPassword)
      ..withWillTopic(_devicesClient!)
      ..withWillMessage('DisconnectedHard-$_loginTime')
      ..withWillRetain()
      ..startClean()
      ..withWillQos(MqttQos.exactlyOnce);

    _mqttClient = MqttServerClient.withPort(
        mqttHost, 'flutter_client/$_deviceId', mqttPort)
      ..secure = true
      ..securityContext = SecurityContext.defaultContext
      ..keepAlivePeriod = 30
      ..securityContext = SecurityContext.defaultContext
      ..connectionMessage = connMessage
      ..onConnected = onConnected
      ..onDisconnected = onDisconnected;
    // _mqttClient.onSubscribed = onSubscribed;`
    // _mqttClient.onUnsubscribed = onUnsubscribed;
    // _mqttClient.onSubscribeFail = onSubscribeFail;
    // _mqttClient.pongCallback = pong;

    try {
      await _mqttClient.connect();
    } catch (e) {
      if (kDebugMode) {
        print('\n\nException: $e');
      }
      // Exception: mqtt-client::NoConnectionException: The maximum allowed connection attempts ({3}) were exceeded. The broker is not responding to the connection request message (Missing Connection Acknowledgement?

      _mqttClient.disconnect();
      _connStatus = ConnectionStatus.disconnected;
      // Notify listeners to de-activate UI todo;
    }
    if (_connStatus == ConnectionStatus.connected) {
      _mqttClient.subscribe("cbes/dekut/#", MqttQos.exactlyOnce);
      void removeFirstElement(List list) {
        // todo, get the data for the past 24 hours

        if (list.length >= 8640) {
          list.removeAt(0);
        }
      }

      // double randomDouble(int min, int max) =>
      //     (Random().nextDouble() * (max - min)) + min;

      // todo REMOVE THIS PART
      // timerDummyData = Timer.periodic(const Duration(seconds: 30), (_) async {
      //   // todo Publish dummy environment data
      //
      //   // var envDummyData = EnvironmentMeter(
      //   //   usage: randomDouble(0, 100).toStringAsFixed(1),
      //   //   temperature: randomDouble(0, 100).toStringAsFixed(1),
      //   //   humidity: randomDouble(0, 100).toStringAsFixed(1),
      //   //   illuminance: randomDouble(50, 500).toStringAsFixed(1),
      //   // ).asMap();
      //   //
      //
      //   var pwrDummyData = PowerUnit(
      //     status: true,
      //     deviceMode: 'Line Mode',
      //     time: DateTime.now().toIso8601String(),
      //     acVoltage: randomDouble(228, 230).toStringAsFixed(1),
      //     acFrequency: randomDouble(49, 52).toStringAsFixed(1),
      //     pvInputVoltage: randomDouble(230, 246).toStringAsFixed(1),
      //     pvInputPower: randomDouble(60, 80).toStringAsFixed(1),
      //     outputApparentPower: randomDouble(80, 100).toStringAsFixed(1),
      //     outputActivePower: randomDouble(80, 100).toStringAsFixed(1),
      //     batteryVoltage: randomDouble(60, 100).toStringAsFixed(1),
      //     batteryCapacity: randomDouble(70, 100).toStringAsFixed(1),
      //     chargingCurrent: randomDouble(7, 10).toStringAsFixed(1),
      //     batteryDischargeCurrent: randomDouble(0, 10).toStringAsFixed(1),
      //     outputVoltage: randomDouble(220, 260).toStringAsFixed(1),
      //     outputFrequency: randomDouble(48, 53).toStringAsFixed(1),
      //   ).asMap();
      //   // todo Publish dummy power unit data
      //   // publishMsg(
      //   //     'cbes/dekut/data/environment_meter', json.encode(envDummyData));
      //   await Future.delayed(const Duration(seconds: 30)).then((_) =>
      //       publishMsg(
      //           'cbes/dekut/data/power_unit', json.encode(pwrDummyData)));
      // });

      // todo change the duration dynamically on request from the client
      timerGraph = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (_heatingUnitData != null) {
          removeFirstElement(temp1GraphData);
          removeFirstElement(temp2GraphData);
          removeFirstElement(temp3GraphData);
          removeFirstElement(flow1GraphData);
          removeFirstElement(flow2GraphData);
          removeFirstElement(temperatureGraphData);
          removeFirstElement(humidityGraphData);
          // removeFirstElement(outputActivePowerGraphData);
          // removeFirstElement(pvPowerGraphData);
          // removeFirstElement(outputVoltageGraphData);

          final time = DateTime.now();

          temp1GraphData.add(GraphAxis(
              _duration(time), double.parse(_heatingUnitData!.tank1!)));
          temp2GraphData.add(GraphAxis(
              _duration(time), double.parse(_heatingUnitData!.tank2!)));
          temp3GraphData.add(GraphAxis(
              _duration(time), double.parse(_heatingUnitData!.tank3!)));
          flow1GraphData.add(GraphAxis(
              _duration(time), double.parse(_heatingUnitData!.flow1!)));
          flow2GraphData.add(GraphAxis(
              _duration(time), double.parse(_heatingUnitData!.flow2!)));
          if (ductMeterData != null) {
            temperatureGraphData.add(GraphAxis(_duration(time),
                double.parse(_environmentMeterData!.temperature!)));
            humidityGraphData.add(GraphAxis(_duration(time),
                double.parse(_environmentMeterData!.humidity!)));
          }

          // outputActivePowerGraphData.add(GraphAxis(_duration(time),
          //     double.parse(_powerUnitData!.outputActivePower!)));
          // pvPowerGraphData.add(GraphAxis(
          //     _duration(time), double.parse(_powerUnitData!.pvInputPower!)));
          // outputVoltageGraphData.add(GraphAxis(
          //     _duration(time), double.parse(_powerUnitData!.outputVoltage!)));
        }
        notifyListeners();
      });
      _mqttClient.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final topic = c[0].topic;
        var message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        if (topic == "cbes/dekut/data/heating_unit") {
          _heatingUnitData =
              HeatingUnit.fromMap(json.decode(message) as Map<String, dynamic>);
          const capacitance = 4182.0;
          const tankTemp = 22.0;

          final flowRate = double.parse(heatingUnitData!.flow1!);
          final temp1 = double.parse(heatingUnitData!.tank1!);
          final temp2 = double.parse(heatingUnitData!.tank2!);
          final temp3 = double.parse(heatingUnitData!.tank3!);

          final mass = flowRate * 0.06 * 2;
          final averageTemp = (temp1 + temp2 + temp3) / 3;
          final enthalpy =
              (mass * capacitance * (averageTemp - tankTemp)) / 1000;
          notifyListeners();
        }

        if (topic == "cbes/dekut/data/environment_meter") {
          print(json.decode(message) as Map<String, dynamic>);
          _environmentMeterData =
              DuctMeter.fromMap(json.decode(message) as Map<String, dynamic>);
          notifyListeners();
        }
        if (topic == "cbes/dekut/data/power_unit") {
          _powerUnitData =
              PowerUnit.fromMap(json.decode(message) as Map<String, dynamic>);
          notifyListeners();
        }
        if (topic.contains("cbes/dekut/devices/")) {
          final deviceData = topic.split('/');
          if (kDebugMode) {
            print('''${deviceData[3]} - ${deviceData[4]}
          State: $message''');
          }
          // todo Get all the devices status and display in the UI,
          //  Disconnected or connected,
          // todo display online users like whatsapp
          // todo Record in firebase how long a user is logged in or logged out?
        }
      });
    }

    return _connStatus;
  }

  void refresh() {
    notifyListeners();
  }

  void publishMsg(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    if (kDebugMode) {
      print('Publishing message "$message" to topic $topic');
    }
    _mqttClient.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!,
        retain: true);
  }

  void onConnected() {
    _connStatus = ConnectionStatus.connected;
    publishMsg(_devicesClient!, 'Connected-$_loginTime');
  }

  void onDisconnected() {
    _connStatus = ConnectionStatus.disconnected;
    timerGraph?.cancel();
    timerDummyData?.cancel();
    notifyListeners();
    // TODO ON DISCONNECTED, FORCE THE USER OFFLINE
    // Use firebase Auth to force the application to HomePage
  }
}
