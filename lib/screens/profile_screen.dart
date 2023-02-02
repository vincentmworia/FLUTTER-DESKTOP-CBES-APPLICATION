import 'package:cbesdesktop/models/logged_in.dart';
import 'package:cbesdesktop/private_data.dart';
import 'package:flutter/material.dart';

import '../providers/firebase_auth.dart';
import '../providers/login_user_data.dart';

// todo Edit Password, delete account, etc
// todo improve the UI

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LoggedIn user = LoginUserData.getLoggedUser!;

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
          children: [ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        cons.smallest.shortestSide * 0.01)),
                fixedSize: Size(cons.smallest.shortestSide * 0.3,
                    cons.smallest.shortestSide * 0.15)),
            onPressed: () {
              FirebaseAuthentication.deleteAccount(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(fontSize: cons.smallest.shortestSide * 0.04),
            ),
          ),ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        cons.smallest.shortestSide * 0.01)),
                fixedSize: Size(cons.smallest.shortestSide * 0.3,
                    cons.smallest.shortestSide * 0.15)),
            onPressed: () {
              FirebaseAuthentication.logout(context);
            },
            child: Text(
              'Logout',
              style: TextStyle(fontSize: cons.smallest.shortestSide * 0.04),
            ),
          ),],)

        ],
      );
    });
  }
}
