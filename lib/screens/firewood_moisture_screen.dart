import 'dart:convert';
import 'dart:math';

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

  static Future<void> showAlertDialog(
          String title, Function yesFn, BuildContext ctx) async =>
      await showDialog(
          context: ctx,
          builder: (ctx) => AlertDialog(
                content: Text(title),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(ctx).colorScheme.secondary),
                          onPressed: () {
                            Navigator.pop(ctx);
                          },
                          child: const Text('No')),
                      ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await yesFn();
                          },
                          child: const Text('Yes')),
                    ],
                  )
                ],
              ));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: HttpProtocol.getFirewoodData(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const MyLoadingAnimation();
          }
          final data = json.decode(snap.data!.body);
          if (data == null) {
            return const FirewoodMoistureData(firewoodData: null);
          }
          return FirewoodMoistureData(
            firewoodData: data as Map<String, dynamic>,
          );
        });
  }
}

class FirewoodMoistureData extends StatefulWidget {
  const FirewoodMoistureData({Key? key, required this.firewoodData})
      : super(key: key);
  final Map<String, dynamic>? firewoodData;

  // final bool decompressNavPlane;
  @override
  State<FirewoodMoistureData> createState() => _FirewoodMoistureDataState();
}

class _FirewoodMoistureDataState extends State<FirewoodMoistureData> {
  final _searchController = TextEditingController();
  final _searchDateTimeController = TextEditingController();
  final _searchMoistureLevelController = TextEditingController();

  final _stackNameController = TextEditingController();
  var _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _stackNameController.dispose();
  }

  void _refreshPage() {
    setState(() {});
  }

  late String _selectedDate;

  void _searchSelectedDate(String? selectedDate) {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select Date')));
      return;
    }
    _selectedDate = selectedDate;
  }

  void _removeMoistureItem(String stackName, String date) {
    (dbFirewoodData[stackName] as Map).removeWhere((key, value) => key == date);
  }

  Future<void> _deleteStack(String pgKey) async {
    await FirewoodMoistureScreen.showAlertDialog('Delete $pgKey?', () async {
      setState(() {
        _isLoading = true;
      });
      await HttpProtocol.deleteFirewoodStack(pgKey);
      setState(() {
        dbFirewoodData.remove(pgKey);
        _pageData = null;
        _isLoading = false;
      });
    }, context);
  }

  Future<void> _addMoistureLevelToStack(
      String pgKey, String date, String moistureLevel) async {
    await FirewoodMoistureScreen.showAlertDialog(
        '$moistureLevel% recorded on date $date?', () async {
      setState(() {
        _isLoading = true;
      });
      await HttpProtocol.addFirewoodStackData(
          stackName: pgKey, newData: {date: moistureLevel});
      setState(() {
        (dbFirewoodData[pgKey] /*as Map<String, String>*/)
            .addAll({date: moistureLevel});
        _isLoading = false;
      });
    }, context);
  }

  void _resetSearchController() {
    setState(() {
      _searchController.text = "";
    });
  }

  Future<void> _addStackBnPressed(BuildContext ctx) async {
    ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
    if (dbFirewoodData.keys.contains(_stackNameController.text)) {
      ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text("The stack already exists")));
    } else if (_stackNameController.text == '') {
      ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text("Fill in the stack name")));
    } else if (_searchDateTimeController.text == '') {
      ScaffoldMessenger.of(ctx)
          .showSnackBar(const SnackBar(content: Text("Enter Date")));
    } else if (_searchMoistureLevelController.text == '') {
      ScaffoldMessenger.of(ctx)
          .showSnackBar(const SnackBar(content: Text("Enter Moisture Level")));
    } else if (_searchMoistureLevelController.text == '') {
      ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text("Moisture Level is a number")));
    } else if (double.tryParse(_searchMoistureLevelController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Moisture Level is a number")));
      return;
    } else {
      Navigator.pop(ctx);
      setState(() {
        _isLoading = true;
      });
      final newData = {_selectedDate: _searchMoistureLevelController.text};
      await HttpProtocol.addFirewoodStackData(
        stackName: _stackNameController.text,
        newData: newData,
      );
      setState(() {
        dbFirewoodData[_stackNameController.text] = newData;
        _isLoading = false;
      });

      _stackNameController.text = '';
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
    dbFirewoodData = widget.firewoodData ?? {};
  }

  Future<void> _cancelPage() async {
    setState(() => _op = 0.0);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _pageData = null);
  }

  @override
  Widget build(BuildContext context) {
    // print(dbFirewoodData);

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
                searchController: _searchController,
                stackNameController: _stackNameController,
                resetSearchController: _resetSearchController,
                refreshPage: _refreshPage,
                addStackBnPressed: _addStackBnPressed,
                searchDateTimeController: _searchDateTimeController,
                searchMoistureLevelController: _searchMoistureLevelController,
                searchSelectedDate: _searchSelectedDate,
                cons: cons,
              ),
              Wrap(
                children: [
                  ...(firewoodData.keys.toList()).map((e) {
                    var i =Random().nextInt(3)+1;
                    return Container(
                      margin: EdgeInsets.all(cons.maxWidth * 0.02),
                      width: cons.maxWidth * 0.155,
                      height: cons.maxWidth * 0.155,
                      child: Card(
                        elevation: 6,
                        shadowColor: Theme.of(context).colorScheme.primary,
                        color: Colors.white.withOpacity(0.65),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: GestureDetector(
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
                                  'images/wood${i.toString()}.jpg',
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
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList()
                ],
              ),
            ],
          ),
          if (_pageData != null)
            FirewoodMoistureDetailedScreen(
              op: _op,
              pageData: _pageData!,
              cancelPage: _cancelPage,
              deleteStack: _deleteStack,
              addMoistureLevelToStack: _addMoistureLevelToStack,
              changeLoadingStatus: (bool val) {
                setState(() {
                  _isLoading = val;
                });
              },
              cons: cons,
              removeMoistureItem: _removeMoistureItem,
            ),
          if (_isLoading) const MyLoadingAnimation()
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
