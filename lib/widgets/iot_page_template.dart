import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mqtt.dart';

import '../widgets/search_toggle_view.dart';
import 'loading_animation.dart';

class IotPageTemplate extends StatefulWidget {
  const IotPageTemplate({
    Key? key,
    required this.gaugePart,
    required this.graphPart,
    required this.onlineBnStatus,
    required this.generateExcel,
    required this.fromController,
    required this.toController,
    required this.searchDatabase,
    required this.loadingStatus,
    required this.activateExcel,
  }) : super(key: key);
  final Widget gaugePart;
  final Widget graphPart;
  final Function onlineBnStatus;
  final Function generateExcel;
  final Function? searchDatabase;
  final TextEditingController fromController;
  final TextEditingController toController;
  final bool loadingStatus;
  final bool activateExcel;

  @override
  State<IotPageTemplate> createState() => _IotPageTemplateState();
}

class _IotPageTemplateState extends State<IotPageTemplate> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(builder: (_, cons) {
          return Consumer<MqttProvider>(
              builder: (context, mqttProv, child) => Row(
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
                              child: widget.gaugePart,
                            ),
                            SearchToggleView(
                              toggleOnlineStatus: widget.onlineBnStatus,
                              generateExcel: widget.generateExcel,
                              fromController: widget.fromController,
                              toController: widget.toController,
                              searchDatabase: widget.searchDatabase,
                              activateExcel: widget.activateExcel,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: widget.graphPart,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ));
        }),
        if (widget.loadingStatus) const MyLoadingAnimation()
      ],
    );
  }
}
