import 'package:flutter/material.dart';

import '../providers/firebase_auth.dart';
import '../providers/login_user_data.dart';
import '../models/logged_in.dart';
import '../private_data.dart';
import '../widgets/loading_animation.dart';

// todo Edit Password, delete account, etc
// todo improve the UI

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var _isLoading = false;

  void dialog(BuildContext context, String operation, LoggedIn user,
          Function yesFn) async =>
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                content: Text('$operation ${user.email}\'s account?'),
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
                            yesFn();
                          },
                          child: const Text('Yes')),
                    ],
                  )
                ],
              ));

  @override
  Widget build(BuildContext ctxMain) {
    LoggedIn user = LoginUserData.getLoggedUser!;

    if (_isLoading) {
      return const MyLoadingAnimation();
    }
    return LayoutBuilder(builder: (context, cons) {
      Widget userData(String title) => Text(
            title,
            style: TextStyle(
                // fontWeight: FontWeight.w500,
                letterSpacing: cons.smallest.shortestSide * 0.005,
                fontSize: cons.smallest.shortestSide * 0.04),
          );
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                radius: cons.smallest.shortestSide * 0.1,
                child: Text(
                  user.firstname[0],
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: cons.smallest.shortestSide * 0.1),
                ),
              ),
              userData(user.email),
              userData('${user.firstname}\t${user.lastname}'),
              userData(user.phoneNumber),
              userData((user.privilege == userSuperAdmin ||
                      user.privilege == userSuperAdmin)
                  ? "Administrator"
                  : "Not Administrator"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            cons.smallest.shortestSide * 0.01)),
                    fixedSize: Size(cons.smallest.shortestSide * 0.3,
                        cons.smallest.shortestSide * 0.15)),
                onPressed: () async {
                  dialog(context, 'Delete', user, () async {
                    setState(
                      () => _isLoading = true,
                    );
                    try {
                      await FirebaseAuthentication.deleteAccount(context, user);
                      if (mounted) {
                        await FirebaseAuthentication.logout(ctxMain);
                      }
                    } catch (e) {
                      setState(() => _isLoading = false);
                    }
                  });
                },
                child: Text(
                  'Delete',
                  style: TextStyle(fontSize: cons.smallest.shortestSide * 0.04),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            cons.smallest.shortestSide * 0.01)),
                    fixedSize: Size(cons.smallest.shortestSide * 0.3,
                        cons.smallest.shortestSide * 0.15)),
                onPressed: () async {
                  dialog(context, 'Logout of', user, () async {
                    await FirebaseAuthentication.logout(ctxMain);
                  });
                },
                child: Text(
                  'Logout',
                  style: TextStyle(fontSize: cons.smallest.shortestSide * 0.04),
                ),
              ),
            ],
          )
        ],
      );
    });
  }
}
