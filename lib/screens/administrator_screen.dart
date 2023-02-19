import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../models/online_user.dart';
import '../providers/mqtt.dart';
import '../widgets/administrator_screen_online_user.dart';
import '../widgets/administrator_screen_user.dart';
import '../widgets/loading_animation.dart';
import '../models/logged_in.dart';
import '../private_data.dart';
import '../providers/firebase_auth.dart';

class AdministratorScreen extends StatefulWidget {
  const AdministratorScreen({Key? key}) : super(key: key);

  @override
  State<AdministratorScreen> createState() => _AdministratorScreenState();
}

class _AdministratorScreenState extends State<AdministratorScreen> {
  Future<void> _allowUsersFunction(
      {required BuildContext context,
      required LoggedIn user,
      required int operation,
      required String title}) async {
    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: Text(title),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('No')),
                    ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);

                          final url =
                              '$firebaseDbUrl/users/${user.localId}.json?auth=${FirebaseAuthentication.idToken}';

                          setState(() {
                            _isLoading = true;
                          });
                          if (operation == 1) {
                            await FirebaseAuthentication.deleteAccount(
                                context, user);
                          } else if (operation == 2) {
                            await http.patch(Uri.parse(url),
                                body: json.encode({'allowed': allowUserTrue}));
                          } else if (operation == 3) {
                            await http.patch(Uri.parse(url),
                                body: json.encode({'privilege': userNormal}));
                          } else if (operation == 4) {
                            await http.patch(
                                Uri.parse(
                                    '$firebaseDbUrl/users/${user.localId}.json?auth=${FirebaseAuthentication.idToken}'),
                                body: json.encode({'privilege': userAdmin}));
                          } else if (operation == 5) {
                            await http.patch(
                                Uri.parse(
                                    '$firebaseDbUrl/users/${user.localId}.json?auth=${FirebaseAuthentication.idToken}'),
                                body: json.encode({'allowed': allowUserFalse}));
                          } else if (operation == 6) {
                            await http.patch(
                                Uri.parse(
                                    '$firebaseDbUrl/users/${user.localId}.json?auth=${FirebaseAuthentication.idToken}'),
                                body: json.encode({'allowed': allowUserTrue}));
                          }
                          setState(() => _isLoading = false);
                        },
                        child: const Text('Yes')),
                  ],
                )
              ],
            ));
  }

  var _isLoading = false;

  Widget _title(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(30.0, 20.0, 20.0, 10.0),
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 22,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MyLoadingAnimation();
    }
    return FutureBuilder(
      future: FirebaseAuthentication.getAllUsers(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MyLoadingAnimation();
        }
        if (snapshot.data["error"] != null) {
          return const MyLoadingAnimation();
        }
        final allUsersData =
            json.decode((snapshot.data["response"] as http.Response).body)
                as Map<String, dynamic>;
        allUsersData.forEach((key, value) {
          allUsersData[key] = LoggedIn.fromMap(value);
        });

        final allowedUsers = <LoggedIn>[
          ...allUsersData.values.toList()
          // .where((element) => element.allowed == allowUserTrue)
          // .toList()
        ];

        return Consumer<MqttProvider>(
          builder: (BuildContext context, devicesProv, Widget? child) {
            List<OnlineUser> onlineUsers = [];
            devicesProv.onlineUsersData.values.toList();

            devicesProv.onlineUsersData.forEach((key, value) {
              if (value.onlineState == OnlineConnectionState.online) {
                onlineUsers.add(value);
              }
            });
            return LayoutBuilder(builder: (context, cons) {
              return Row(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: cons.maxWidth * 0.15,
                    child: ListView(
                      children: [
                        _title(context, 'Online Users'),
                        ...onlineUsers
                            .map((e) => AdministratorScreenOnlineUser(
                          cons: cons,
                          e: e,
                        ))
                            .toList()
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _title(context, 'All Users'),
                        Expanded(
                            child: ListView.builder(
                                // separatorBuilder: (context, index) => const Divider(),
                                itemCount: allowedUsers.length,
                                itemBuilder: (ctx, i) {
                                  final usr = allowedUsers[i];
                                  return AdministratorScreenUser(
                                      allowUsersFunction: _allowUsersFunction,
                                      cons: cons,
                                      usr: usr);
                                }))
                      ],
                    ),
                  )
                ],
              );
            });
          },
        );
      },
    );
  }
}
