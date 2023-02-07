import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/loading_animation.dart';
import '../private_data.dart';

class FirewoodMoistureScreen extends StatelessWidget {
  const FirewoodMoistureScreen({super.key});

  // TODO Add Stack
  // TODO Add item in stack

  // TODO delete Stack
  // TODO delete item in stack

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
            firewoodData: data as Map<String, dynamic>,
          );
        });
  }
}

class FirewoodMoistureData extends StatefulWidget {
  const FirewoodMoistureData({Key? key, required this.firewoodData})
      : super(key: key);
  final Map<String, dynamic> firewoodData;

  // final bool decompressNavPlane;

  @override
  State<FirewoodMoistureData> createState() => _FirewoodMoistureDataState();
}

class _FirewoodMoistureDataState extends State<FirewoodMoistureData> {

  final _controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Map<String, dynamic> firewoodData = {};

  // var _openPage = false;
  var _op = 0.0;
  Map? _pageData;

  @override
  Widget build(BuildContext context) {
    if (_controller.text == "") {
      firewoodData = widget.firewoodData;
    } else {
      // print(_controller.text);
      firewoodData = {};
      widget.firewoodData.forEach((key, value) {
        if (key.contains(_controller.text)) {
          firewoodData[key] = value;
        }
      });
    }
    print(_pageData);
    return LayoutBuilder(builder: (_, cons) {
      return Stack(
        children: [
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(width: 0.8),
                    ),
                    hintText: 'Search stack number',
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              _controller.text = "";
                            });
                          },
                          icon: const Icon(
                            Icons.clear,
                            size: 30,
                          )),
                    ),
                  ),
                ),
              ),
              Wrap(
                children: [
                  ...(firewoodData.keys.toList())
                      .map((e) => Container(
                            margin: EdgeInsets.all(cons.maxWidth * 0.01),
                            width: cons.maxWidth * 0.15,
                            height: cons.maxWidth * 0.15,
                            child: Card(
                              elevation: 6,
                              shadowColor:
                                  Theme.of(context).colorScheme.primary,
                              color: Colors.white.withOpacity(0.65),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                splashColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.4),
                                onTap: () {
                                  setState(() {
                                    // _openPage = true;
                                    _pageData = {e: firewoodData[e]};
                                    _op = 1.0;
                                  });
                                },
                                child: Center(
                                    child: ListTile(
                                  title: Text(e),
                                  subtitle:
                                      Text(firewoodData[e].length.toString()),
                                )),
                              ),
                            ),
                          ))
                      .toList()
                ],
              ),
            ],
          ),
          if (_pageData != null)
            AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _op,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Center(
                        child: Text(_pageData.toString()),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: Icon(
                            Icons.cancel,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _pageData = null;
                              // _openPage = false;
                              _op = 0.0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )),
          // AnimatedContainer(
          //   duration: const Duration(milliseconds: 300),
          //   color: _stackPressed != -1
          //       ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
          //       : Colors.white,
          //   height: double.infinity,
          //   width: _stackPressed < 0 ? width : 0,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       GestureDetector(
          //         onTap: () {
          //           setState(() {
          //             _stackPressed = 1;
          //           });
          //         },
          //         child: Container(
          //           width: 100,
          //           height: 100,
          //           color: Colors.red,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // Expanded(
          //     child: Stack(
          //   children: [
          //     Positioned(
          //       top: 10,
          //       right: 10,
          //       child: IconButton(
          //         icon: Icon(
          //           Icons.cancel,
          //           color: Theme.of(context).colorScheme.secondary,
          //         ),
          //         onPressed: () {
          //           setState(() {
          //             _stackPressed = -1;
          //           });
          //         },
          //       ),
          //     ),
          //   ],
          // ))
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
