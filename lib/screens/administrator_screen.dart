import 'dart:convert';
import 'package:cbesdesktop/providers/mqtt.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../models/online_user.dart';
import '../providers/mqtt_devices_provider.dart';
import '../widgets/loading_animation.dart';
import '../models/logged_in.dart';
import '../private_data.dart';
import '../providers/firebase_auth.dart';

class AdministratorScreen extends StatelessWidget {
  const AdministratorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuthentication.getAllUsers(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MyLoadingAnimation();
        }
        if (snapshot.data["error"] != null) {
          print("error");
          return const MyLoadingAnimation();
        }
        final allUsersData =
            json.decode((snapshot.data["response"] as http.Response).body)
                as Map<String, dynamic>;
        allUsersData.forEach((key, value) {
          allUsersData[key] = LoggedIn.fromMap(value);
        });

        List allowedUsers = allUsersData.values
            .toList()
            .where((element) => element.allowed == allowUserTrue)
            .toList();
        List notAllowedUsers = allUsersData.values
            .toList()
            .where((element) => element.allowed != allowUserTrue)
            .toList();

        return Consumer<MqttProvider>(
          builder: (BuildContext context, devicesProv, Widget? child) {
            // todo Filter list of online users like whatsapp, differentiate windows and android

            print("Trigger");
            List<OnlineUser> onlineUsers = [];
            devicesProv.onlineUsersData.values.toList();

            devicesProv.onlineUsersData.forEach((key, value) {
              if (value.onlineState == OnlineConnectionState.online) {
              onlineUsers.add(value);
              }
            });

            print(devicesProv.onlineUsersData);
            return Center(
              child: Text("""
          Online: ${devicesProv.onlineUsersData.values.toList()}

          Allowed Users: $allowedUsers
          Not Allowed Users: $notAllowedUsers

          - Viewing online users in realtime
          - Allow Users to access application
          - Promoting users to administrators
          - Demoting users to normal users
          - An 'Online Message View' showing all the actions that have been undertaken in the application?
          """),
            );
          },
        );
      },
    );
  }
}
/*

            return Center(
              child: Text("""
          Online: ${mqttProv.onlineUsersData.values.toList()}

          Allowed Users: $allowedUsers
          Not Allowed Users: $notAllowedUsers

          - Viewing online users in realtime
          - Allow Users to access application
          - Promoting users to administrators
          - Demoting users to normal users
          - An 'Online Message View' showing all the actions that have been undertaken in the application?
          """),
            );
*/
