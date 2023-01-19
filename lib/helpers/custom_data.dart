import 'package:flutter/material.dart';

OutlineInputBorder customOutlinedInputBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      gapPadding: 4.0,
      borderSide: BorderSide(
        color: color,
        width: 2.0,
      ),
    );

Widget customTextFormField(
        {required BuildContext context,
        required String hintText,
        required String labelText,
        required IconData icon}) =>
    TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,

        prefixIcon: Icon(icon),
        hintText: hintText,
        // labelText: labelText,
        focusedBorder:
            customOutlinedInputBorder(Theme.of(context).colorScheme.primary),
        enabledBorder: customOutlinedInputBorder(Colors.grey),
      ),
    );

Widget customIcon(IconData icon, Color color) => Icon(
      icon,
      size: 30.0,
      color: color,
    );

Future<dynamic> customDialog(BuildContext context, String message) async =>
    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              // title: const Text(''),
              content: Text(message),
              actions: [
                Center(
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Okay')),
                )
              ],
            ));

List<String> alphabet = [
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
];
