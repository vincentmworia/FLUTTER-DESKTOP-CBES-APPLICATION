import 'package:cbesdesktop/models/graph_axis.dart';
import 'package:cbesdesktop/widgets/search_toggle_view.dart';
import 'package:cbesdesktop/widgets/tank_graph.dart';
import 'package:flutter/material.dart';

class FirewoodMoistureDetailedScreen extends StatefulWidget {
  const FirewoodMoistureDetailedScreen(
      {Key? key,
      required this.op,
      required this.pageData,
      required this.cancelPage,
      required this.deleteStack})
      : super(key: key);
  final double op;
  final Map<String, dynamic> pageData;
  final Function cancelPage;
  final Function deleteStack;

  @override
  State<FirewoodMoistureDetailedScreen> createState() =>
      _FirewoodMoistureDetailedScreenState();
}

class _FirewoodMoistureDetailedScreenState
    extends State<FirewoodMoistureDetailedScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  void _searchDatabase() {}

  void _generateExcel() {}

  @override
  Widget build(BuildContext context) {
    final graphData = <GraphAxis>[];
    (widget.pageData[widget.pageData.keys.first] as Map).forEach((key, value) {
      graphData.add(GraphAxis.fromMap({key: value}));
    });
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
                            SizedBox(
                              height: cons.maxHeight * 0.5,
                              // width:  cons.maxWidth * 0.5,

                              // todo Break the child into a widget
                              child: Container(
                                color: Colors.grey,
                              ),
                            ),
                            SearchToggleView(
                              toggleOnlineStatus: null,
                              generateExcel: _generateExcel,
                              fromController: _fromController,
                              toController: _toController,
                              searchDatabase: _searchDatabase,
                              activateExcel: graphData.isNotEmpty, formKey: GlobalKey<FormState>(),
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
                                // !_online ? flow1HistoryGraphData : mqttProv.flow2GraphData,
                                // spline2Title: "Flow (To Heat Exchanger)",
                                // spline2DataSource:
                                // !_online ? flow2HistoryGraphData : mqttProv.flow1GraphData,
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
