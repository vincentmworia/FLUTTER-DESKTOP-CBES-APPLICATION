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
  final _searchController = TextEditingController();
  final _stackNameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _stackNameController.dispose();
  }

  Map<String, dynamic> firewoodData = {};

  // var _openPage = false;
  var _op = 0.0;
  Map? _pageData;

  @override
  Widget build(BuildContext context) {
    if (_searchController.text == "") {
      firewoodData = widget.firewoodData;
    } else {
      // print(_controller.text);
      firewoodData = {};
      widget.firewoodData.forEach((key, value) {
        if (key.contains(_searchController.text)) {
          firewoodData[key] = value;
        }
      });
    }
    return LayoutBuilder(builder: (_, cons) {
      return Stack(
        children: [
          ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(width: 0.8),
                          ),
                          hintText: 'Search Stack by Id',
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _searchController.text = "";
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
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                    content: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: _stackNameController,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.all(20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide:
                                                const BorderSide(width: 0.8),
                                          ),
                                          hintText: 'Enter Stack ID',
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () async {
                                            if (widget.firewoodData.keys
                                                .contains(_stackNameController
                                                    .text)) {
                                              print('The stack already exists');
                                            } else {
                                              print('DN#');
                                            }
                                            // print(_stackNameController.text);
                                            // todo, should be a trial and error,
                                            //  todo in case of any error, Display the error
                                            // todo
                                          },
                                          child: const Text('Ok'))
                                    ],
                                  ));
                        },
                        label: const Text('Add Stack')),
                  )
                ],
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
                                onTap: () async {
                                  setState(() {
                                    // _openPage = true;
                                    _pageData = {e: firewoodData[e]};
                                  });
                                  await Future.delayed(
                                      Duration(milliseconds: 100));
                                  setState(() {
                                    _op = 1;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: FractionalOffset.center,
                                        child: Text(
                                          e,
                                          style: const TextStyle(
                                              overflow: TextOverflow.fade,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    // IconButton(
                                    //     onPressed: () {},
                                    //     icon: Icon(
                                    //       Icons.delete,
                                    //       color: Theme.of(context)
                                    //           .colorScheme
                                    //           .secondary,
                                    //     ))
                                  ],
                                ),
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
                duration: const Duration(milliseconds: 500),
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
                        top: 15,
                        right: 15,
                        child: IconButton(
                          iconSize: 30.0,
                          icon: Icon(
                            Icons.cancel,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () async {
                            setState(() => _op = 0.0);
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                            setState(() => _pageData = null);
                          },
                        ),
                      ),
                    ],
                  ),
                )),
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
