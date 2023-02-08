import 'dart:convert';
import 'package:flutter/material.dart';

import '../widgets/loading_animation.dart';
import '../providers/https_protocol.dart';
import '../widgets/firewood_moisture_detailed_screen.dart';
import '../widgets/firewood_moisture_search_and_add_stack.dart';

class FirewoodMoistureScreen extends StatelessWidget {
  const FirewoodMoistureScreen({super.key});

  // TODO Add Stack
  // TODO Add item in stack

  // TODO delete Stack
  // TODO delete item in stack

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: HttpProtocol.getFirewoodData(),
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

  void _refreshPage() {
    setState(() {});
  }

  void _resetSearchController() {
    setState(() {
      _searchController.text = "";
    });
  }

  Future<void> _addStackBnPressed(BuildContext ctx) async {
    if (dbFirewoodData.keys.contains(_stackNameController.text)) {
      print('The stack already exists');
    } else if (_stackNameController.text == '') {
      print('Fill in the stack name');
    } else {
      await HttpProtocol.addFirewoodStack(_stackNameController.text);
      setState(() {
        dbFirewoodData[_stackNameController.text] = {};
      });

      _stackNameController.text = '';
      await Future.delayed(Duration.zero).then((value) => Navigator.pop(ctx));
    }

    // print(_stackNameController.text);
    // todo, should be a trial and error,
    //  todo in case of any error, Display the error
    // todo
  }

  Map<String, dynamic> firewoodData = {};

  // var _openPage = false;
  var _op = 0.0;
  Map<String, dynamic>? _pageData;
  late Map<String, dynamic> dbFirewoodData;

  @override
  void initState() {
    super.initState();
    dbFirewoodData = widget.firewoodData;
  }

  Future<void> _cancelPage() async {
    setState(() => _op = 0.0);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _pageData = null);
  }

  @override
  Widget build(BuildContext context) {
    print(dbFirewoodData);

    if (_searchController.text == "") {
      firewoodData = dbFirewoodData;
    } else {
      firewoodData = {};
      dbFirewoodData.forEach((key, value) {
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
              FirewoodMoistureSearchAndAddStack(
                  searchController: _stackNameController,
                  stackNameController: _stackNameController,
                  resetSearchController: _resetSearchController,
                  refreshPage: _refreshPage,
                  addStackBnPressed: _addStackBnPressed),
              Wrap(
                children: [
                  ...(firewoodData.keys.toList())
                      .map((e) => Container(
                            margin: EdgeInsets.all(cons.maxWidth * 0.02),
                            width: cons.maxWidth * 0.155,
                            height: cons.maxWidth * 0.155,
                            child: Card(
                              elevation: 6,
                              shadowColor:
                                  Theme.of(context).colorScheme.primary,
                              color: Colors.white.withOpacity(0.65),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                // splashColor: Theme.of(context)
                                //     .colorScheme
                                //     .primary
                                //     .withOpacity(0.9),
                                onTap: () async {
                                  setState(() {
                                    // _openPage = true;
                                    _pageData = {e: firewoodData[e]};
                                  });
                                  await Future.delayed(
                                      const Duration(milliseconds: 100));
                                  setState(() {
                                    _op = 1;
                                  });
                                },
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        'images/wood1.jpg',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.5),
                                        )),
                                    Column(
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment: FractionalOffset.center,
                                            child: Text(
                                              e,
                                              style: const TextStyle(
                                                  overflow: TextOverflow.fade,
                                                  color: Colors.white,
                                                  fontSize: 25.0,
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
            FirewoodMoistureDetailedScreen(
                op: _op, pageData: _pageData!, cancelPage: _cancelPage),
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
