import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/linear_gauge.dart';
import '../widgets/tank_graph.dart';
import '../providers/mqtt.dart';
import '../widgets/toggle_online_view.dart';

class IotPageTemplate extends StatefulWidget {
  const IotPageTemplate(
      {Key? key,
      required this.gaugePart,
      required this.graphPart,
      required this.onlineBnStatus})
      : super(key: key);
  final Widget gaugePart;
  final Widget graphPart;
  final Function onlineBnStatus;

  @override
  State<IotPageTemplate> createState() => _IotPageTemplateState();
}

class _IotPageTemplateState extends State<IotPageTemplate> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      return Consumer<MqttProvider>(builder: (context, mqttProv, child) {
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
                    child: widget.gaugePart,
                  ),
                  ToggleOnlineView(toggleOnlineStatus: widget.onlineBnStatus),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    // todo Break widget
                    child: widget.graphPart,
                  ),
                ],
              ),
            ),
          ],
        );
      });
    });
  }
}
