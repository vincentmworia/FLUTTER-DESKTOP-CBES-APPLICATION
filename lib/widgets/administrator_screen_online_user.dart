import 'package:flutter/material.dart';

import '../models/online_user.dart';

class AdministratorScreenOnlineUser extends StatelessWidget {
  const AdministratorScreenOnlineUser(
      {Key? key, required this.e, required this.cons})
      : super(key: key);

  final OnlineUser e;
  final BoxConstraints cons;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: cons.maxWidth * 0.05,
          // height: cons.maxHeight * 0.5,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary),
          child: Container(
            margin: const EdgeInsets.all(2),
            height: cons.maxHeight * 0.1,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.75)),
            child: Center(
                child: Text(
              e.firstName[0],
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            )),
          ),
        ),
        const SizedBox(height: 1,),
        Text(
          '${e.firstName} ${e.lastName}',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        )
        // Text(e.email.substring(0,e.email.indexOf('@')))
      ],
    );
  }
}
