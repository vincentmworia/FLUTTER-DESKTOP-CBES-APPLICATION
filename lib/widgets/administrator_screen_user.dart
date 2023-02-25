import 'package:flutter/material.dart';

import '../private_data.dart';
import '../models/logged_in.dart';

class AdministratorScreenUser extends StatelessWidget {
  const AdministratorScreenUser(
      {Key? key,
      required this.usr,
      required this.cons,
      required this.allowUsersFunction})
      : super(key: key);

  final LoggedIn usr;
  final BoxConstraints cons;
  final Function allowUsersFunction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:   EdgeInsets.symmetric(horizontal: cons.maxWidth*0.05, vertical: cons.maxHeight*0.0025),
      child: Card(
        elevation: 6,
        shadowColor: Theme.of(context).colorScheme.primary,
        color: Colors.white.withOpacity(0.65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          height: 100,
          child: Center(
            child: ListTile(
              leading: Container(
                width: 120,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary),

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
                    usr.firstname[0],
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  )),
                  // height: 100,
                ),
                // height: 100,
              ),
              title: Text(usr.email),
              subtitle: Text('${usr.firstname}\t${usr.lastname}'),
              trailing: SizedBox(
                // color: Colors.red,
                width: 350,
                // height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (usr.allowed == allowUserTrue) {
                          allowUsersFunction(
                              context: context,
                              user: usr,
                              operation: 5,
                              title:
                                  'Do you want to de-activate ${usr.email}\'s account?');
                        } else {
                          allowUsersFunction(
                              context: context,
                              user: usr,
                              operation: 6,
                              title:
                                  'Do you want to activate ${usr.email}\'s account?');
                        }
                      },
                      iconSize: 30,
                      icon: Icon(
                          usr.allowed == allowUserTrue
                              ? Icons.minimize
                              : Icons.add,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    IconButton(
                      onPressed: () {
                        if ((usr.privilege == userSuperAdmin) ||
                            (usr.privilege == userAdmin)) {
                          allowUsersFunction(
                              context: context,
                              user: usr,
                              operation: 3,
                              title:
                                  'Do you want to demote ${usr.email} from an administrator?');
                        } else {
                          allowUsersFunction(
                              context: context,
                              user: usr,
                              operation: 4,
                              title:
                                  'Do you want to promote ${usr.email} to an administrator?');
                        }
                      },
                      iconSize: 30,
                      icon: Icon(
                        Icons.admin_panel_settings,
                        color: Theme.of(context).colorScheme.primary.withOpacity(
                            (usr.privilege == userSuperAdmin) ||
                                    (usr.privilege == userAdmin)
                                ? 1
                                : 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
