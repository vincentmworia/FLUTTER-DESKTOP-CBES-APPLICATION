import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield_new.dart';

import '../models/graph_axis.dart';
import './search_toggle_view.dart';
import './tank_graph.dart';

class FirewoodMoistureDetailedScreen extends StatefulWidget {
  const FirewoodMoistureDetailedScreen(
      {Key? key,
      required this.op,
      required this.pageData,
      required this.cancelPage,
      required this.deleteStack,
      required this.addMoistureLevelToStack})
      : super(key: key);
  final double op;
  final Map<String, dynamic> pageData;
  final Function cancelPage;
  final Function deleteStack;
  final Function addMoistureLevelToStack;

  @override
  State<FirewoodMoistureDetailedScreen> createState() =>
      _FirewoodMoistureDetailedScreenState();
}

class _FirewoodMoistureDetailedScreenState
    extends State<FirewoodMoistureDetailedScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  final _dateTimeController = TextEditingController();
  final _moistureLevelController = TextEditingController();
  var _selectedDateAndTime = '';

  void _searchDatabase() {}

  void _generateExcel() {}

  @override
  void dispose() {
    super.dispose();
    _dateTimeController.dispose();
    _moistureLevelController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final graphData = <GraphAxis>[];
    (widget.pageData[widget.pageData.keys.first] as Map).forEach((key, value) {
      graphData.add(GraphAxis.fromMap({key: value}));
    });
    // todo Filter graph data by date???
    // todo By default, get all data
    return AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: widget.op,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: IconButton(
                      iconSize: 30.0,
                      icon: Icon(
                        Icons.cancel,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () async => await widget.cancelPage(),
                    ),
                  ),
                  Expanded(
                      child: Center(
                    child: Text(
                      widget.pageData.keys.first,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 25),
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: IconButton(
                      iconSize: 30.0,
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () async =>
                          await widget.deleteStack(widget.pageData.keys.first),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: LayoutBuilder(builder: (context, cons) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: cons.maxHeight * 0.05,
                          horizontal: cons.maxWidth * 0.005,
                        ),
                        width: cons.maxWidth * 0.4,
                        height: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Card(
                              // todo Decorate here
                              elevation: 0,
                              shadowColor:
                                  Theme.of(context).colorScheme.primary,
                              color: Colors.white.withOpacity(0.65),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: Column(
                                children: [
                                  if (MediaQuery.of(context).size.height > 650)
                                    Center(
                                      child: Text(
                                        "Add Moisture Level",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontSize: 25),
                                      ),
                                    ),
                                  SizedBox(
                                    height: cons.maxHeight * 0.5,
                                    width: cons.maxWidth * 0.3,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        DateTimeField(
                                          format:
                                              DateFormat("yyyy-MM-dd HH:mm"),
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.all(20),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                borderSide: const BorderSide(
                                                    width: 0.8),
                                              ),
                                              hintText: 'Select Date and Time',
                                              counterText: "Date and Time"),
                                          // format: DateFormat("EEE, MMM d yyyy h:mm a"),
                                          controller: _dateTimeController,

                                          // onFieldSubmitted: (value) {
                                          // },
                                          // validator: ,
                                          // cursorRadius: Radius.circular(200),

                                          showCursor: true,
                                          validator: (value) {
                                            if (value == null) {
                                              return "Select Date and Time";
                                            }
                                            return null;
                                          },

                                          onShowPicker:
                                              (context, currentValue) async {
                                            final currentTime = DateTime.now();
                                            final date = await showDatePicker(
                                                context: context,
                                                firstDate:
                                                    DateTime(2023, 1, 10, 0, 0),
                                                initialDate: currentValue ??
                                                    DateTime.now(),
                                                lastDate: DateTime(
                                                  currentTime.year,
                                                  currentTime.month,
                                                  currentTime.day,
                                                  currentTime.hour,
                                                  currentTime.minute,
                                                ));
                                            if (date != null) {
                                              TimeOfDay? time;
                                              await Future.delayed(
                                                      Duration.zero)
                                                  .then((value) async => time =
                                                          await showTimePicker(
                                                        context: context,
                                                        initialTime: TimeOfDay
                                                            .fromDateTime(
                                                                currentValue ??
                                                                    DateTime
                                                                        .now()),
                                                      ));

                                              final dateTimeSelected =
                                                  DateTimeField.combine(
                                                      date, time);

                                              _dateTimeController
                                                  .text = DateFormat(
                                                      "EEE, MMM d yyyy h:mm a")
                                                  .format(dateTimeSelected);
                                              _selectedDateAndTime =
                                                  DateFormat("yyyy-MM-dd HH:mm")
                                                      .format(dateTimeSelected);
                                            } else {
                                              return currentValue;
                                            }
                                          },
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide:
                                                  const BorderSide(width: 0.8),
                                            ),
                                            hintText: 'Enter Moisture Level',
                                            counterText: 'Moisture Level',
                                          ),
                                          controller: _moistureLevelController,
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            ScaffoldMessenger.of(context)
                                                .hideCurrentSnackBar();
                                            if (_selectedDateAndTime == '') {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content:
                                                          Text("Enter Date")));
                                              return;
                                            }
                                            if (_moistureLevelController.text ==
                                                '') {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          "Enter Moisture Level")));
                                              return;
                                            }
                                            if (double.tryParse(
                                                    _moistureLevelController
                                                        .text) ==
                                                null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          "Moisture Level is a number")));
                                              return;
                                            }
                                            await widget
                                                .addMoistureLevelToStack(
                                                    widget.pageData.keys.first,
                                                    _selectedDateAndTime,
                                                    _moistureLevelController
                                                        .text);
                                          },
                                          icon: const Icon(Icons.add),
                                          label: const Text('Add'),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SearchToggleView(
                              toggleOnlineStatus: null,
                              generateExcel: _generateExcel,
                              fromController: _fromController,
                              toController: _toController,
                              searchDatabase: _searchDatabase,
                              activateExcel: graphData.isNotEmpty,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              // todo Break widget
                              child: MworiaGraph(
                                axisTitle: "Firewood Moisture Level (ml)",
                                spline1Title: "Firewood Moisture Level",
                                spline1DataSource: graphData,
                                graphTitle:
                                    'Graph of Firewood Moisture Level against Time',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              )
            ],
          ),
        ));
  }
}
