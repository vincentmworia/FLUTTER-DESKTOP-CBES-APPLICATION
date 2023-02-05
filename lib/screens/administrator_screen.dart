import 'dart:convert';

import 'package:cbesdesktop/providers/login_user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../models/online_user.dart';
import '../providers/mqtt.dart';
import '../providers/mqtt_devices_provider.dart';
import '../widgets/allow_users_controller.dart';
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
      BuildContext context, LoggedIn user, bool operation) async {
    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: Text(
                  'Do you want to ${operation ? 'add' : 'remove'} ${user.email} ${operation ? 'to' : 'from'} the application'),
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
                          if (!(operation)) {
                            print('Delete User');
                            setState(() {
                              _isLoading = true;
                            });

                            await FirebaseAuthentication.deleteAnotherAccount(
                                    context, user)
                                .then((value) => setState(
                                      () => _isLoading = false,
                                    ));
                          } else {
                            print('Add');
                          }
                          // todo Allow user or delete user from the database, etc...
                          // todo widget.allowUser(operation == true ? 1 : 0, user);
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
          print("error");
          return const MyLoadingAnimation();
        }
        final allUsersData =
            json.decode((snapshot.data["response"] as http.Response).body)
                as Map<String, dynamic>;
        allUsersData.forEach((key, value) {
          allUsersData[key] = LoggedIn.fromMap(value);
        });

        final allowedUsers = <LoggedIn>[
          ...allUsersData.values
              .toList()
              .where((element) => element.allowed == allowUserTrue)
              .toList()
        ];
        print(allowedUsers);
        final notAllowedUsers = <LoggedIn>[
          ...allUsersData.values
              .toList()
              .where((element) => element.allowed != allowUserTrue)
              .toList()
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

            // print(devicesProv.onlineUsersData);
            return LayoutBuilder(builder: (context, cons) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: cons.maxHeight * 0.15,
                    width: cons.maxWidth,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ...onlineUsers
                              .map((e) => Column(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: 120,
                                          margin: const EdgeInsets.all(10),
                                          height: cons.maxHeight * 0.2,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),

                                          child: Container(
                                            // width: 50,
                                            margin: const EdgeInsets.all(2),
                                            height: cons.maxHeight * 0.1,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.75)),
                                            child: Center(
                                                child: Text(
                                              e.firstName[0],
                                              style: const TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white),
                                            )),
                                            // height: 100,
                                          ),
                                          // height: 100,
                                        ),
                                      ),
                                      Text(
                                        '${e.firstName} ${e.lastName}',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      )
                                      // Text(e.email.substring(0,e.email.indexOf('@')))
                                    ],
                                  ))
                              .toList()
                        ],
                      ),
                    ),
                  ),
                  if (notAllowedUsers.isNotEmpty)
                    Expanded(
                      child: Column(
                        children: [
                          _title(context, 'Grant access'),
                          Expanded(
                              child: Wrap(
                            children: [
                              ...notAllowedUsers
                                  .map((e) => Container(
                                        width: cons.maxWidth * 0.3,
                                        height: 85,
                                        margin: const EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                offset: Offset(0, 2),
                                                blurRadius: 6.0,
                                              )
                                            ]),
                                        child: LayoutBuilder(
                                            builder: (context, constraints) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 25.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                      ),
                                                      child: IconButton(
                                                        onPressed: () =>
                                                            _allowUsersFunction(
                                                                context,
                                                                e,
                                                                false),
                                                        icon: const Icon(
                                                            Icons.remove,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child: Center(
                                                            child: Text(
                                                      e.email,
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ))),
                                                    Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.green,
                                                      ),
                                                      child: IconButton(
                                                        onPressed: () =>
                                                            _allowUsersFunction(
                                                                context,
                                                                e,
                                                                true),
                                                        icon: const Icon(
                                                            Icons.add,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          );
                                        }),
                                      ))
                                  .toList()
                            ],
                          ))
                        ],
                      ),
                      // child: AdminAllowUsers(allowedUsers),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (allowedUsers.isNotEmpty)
                    Expanded(
                        child: ListView.builder(
                            // separatorBuilder: (context, index) => const Divider(),
                            itemCount: allowedUsers.length,
                            itemBuilder: (ctx, i) {
                              final usr = allowedUsers[i];
                              return Card(
                                elevation: 8,
                                shadowColor:
                                    Theme.of(context).colorScheme.primary,
                                color: Colors.white.withOpacity(0.65),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: SizedBox(
                                  // width: cons.maxWidth*0.4,
                                  height: 75,
                                  child: ListTile(
                                    title: Text(usr.email),
                                    subtitle: Text(
                                        '${usr.firstname}\t${usr.lastname}'),
                                    trailing: Container(
                                      // color: Colors.red,
                                      width: 350,
                                      // height: 50,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              if((usr.privilege ==
                                                  userSuperAdmin) ||
                                                  (usr.privilege ==
                                                      userAdmin)){
                                                print('Demote User');
                                              }else{
                                                print('promote user');
                                              }
                                            },
                                            iconSize: 30,
                                            icon: Icon(
                                              Icons.admin_panel_settings,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity((usr.privilege ==
                                                              userSuperAdmin) ||
                                                          (usr.privilege ==
                                                              userAdmin)
                                                      ? 1
                                                      : 0.2),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {},
                                            iconSize: 30,
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }))
                ],
              );
            });
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
