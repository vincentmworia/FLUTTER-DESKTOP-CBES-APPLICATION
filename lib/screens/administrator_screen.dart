import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../models/online_user.dart';
import '../providers/mqtt.dart';
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
          builder: (BuildContext context, mqttProv, Widget? child) {
            // todo Filter list of online users like whatsapp, differentiate windows and android

            List<OnlineUser> onlineUsers = [];
            mqttProv.onlineUsersData.values.toList();
            mqttProv.onlineUsersData.forEach((key, value) {
              if (value.onlineState == OnlineConnectionState.online) {
                onlineUsers.add(value);
              }
            });

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
          },
        );
      },
    );
  }
}
