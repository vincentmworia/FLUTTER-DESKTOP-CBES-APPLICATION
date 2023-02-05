import 'dart:convert';

import 'package:cbesdesktop/private_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/loading_animation.dart';

class FirewoodMoistureScreen extends StatelessWidget {
  const FirewoodMoistureScreen({super.key, required this.decompressNavPlane});

  final bool decompressNavPlane;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: http.get(Uri.parse('$firebaseDbUrl/cbes_data/firewood.json')),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const MyLoadingAnimation();
          }
          final data = json.decode(snap.data!.body) as Map;
          return FirewoodMoistureData(
            firewoodData: data,
            decompressNavPlane: decompressNavPlane,
          );
        });
  }
}

class FirewoodMoistureData extends StatefulWidget {
  const FirewoodMoistureData(
      {Key? key, required this.firewoodData, required this.decompressNavPlane})
      : super(key: key);
  final Map firewoodData;
  final bool decompressNavPlane;

  @override
  State<FirewoodMoistureData> createState() => _FirewoodMoistureDataState();
}

class _FirewoodMoistureDataState extends State<FirewoodMoistureData> {
  var _stackPressed = -1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      final width = cons.maxWidth;
      return Row(
        children: [
          AnimatedContainer(
            duration:
            Duration(milliseconds: widget.decompressNavPlane ? 0 : 300),
            color: _stackPressed != -1
                ? Theme
                .of(context)
                .colorScheme
                .secondary
                .withOpacity(0.2)
                : Colors.white,
            height: double.infinity,
            width: _stackPressed < 0 ? width : width * 0.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _stackPressed = 1;
                    });
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          // if(_stackPressed!=-1)
          // VerticalDivider(),
          Expanded(
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Theme
                            .of(context)
                            .colorScheme
                            .secondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _stackPressed = -1;
                        });
                      },
                    ),),
                ],
              ))
        ],
      );
    });
  }
}

// Firewood Moisture
// - Date
// - Stack Number
// - Moisture Value
//
// - Graph of historical data?
// - List of all moisture data
//
// - Search moisture  for particular stack number
// - CRUD Stack number, and the data contents
//
// - Generate excel
