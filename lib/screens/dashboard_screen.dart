import 'package:flutter/material.dart';

import '../widgets/dashboard_screen_environment_meter_consumer.dart';
import '../widgets/dashboard_screen_power_unit_consumer.dart';
import '../widgets/dashboard_screen_heating_unit_consumer.dart';
import './home_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key, required this.switchDashboardPage})
      : super(key: key);
  final Function switchDashboardPage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (builder, cons) {
      final bdRadius = BorderRadius.circular(10);
      Widget cardView(String title, Widget? child) => GestureDetector(
            onDoubleTap: () {
              if (title == HomeScreen.pageTitle(PageTitle.solarHeaterMeter)) {
                switchDashboardPage(PageTitle.solarHeaterMeter,
                    HomeScreen.pageTitle(PageTitle.solarHeaterMeter));
              }
              if (title == HomeScreen.pageTitle(PageTitle.environmentMeter)) {
                switchDashboardPage(PageTitle.environmentMeter,
                    HomeScreen.pageTitle(PageTitle.environmentMeter));
              }
              if (title == HomeScreen.pageTitle(PageTitle.electricalEnergyMeter)) {
                switchDashboardPage(PageTitle.electricalEnergyMeter,
                    HomeScreen.pageTitle(PageTitle.electricalEnergyMeter));
              }
            },
            child: Card(
              elevation: 8,
              shadowColor: Theme.of(context).colorScheme.primary,
              color: Colors.white.withOpacity(0.65),
              shape: RoundedRectangleBorder(borderRadius: bdRadius),
              child: SizedBox(
                width: title == 'Power Unit'
                    ? cons.maxWidth * 0.875
                    : cons.maxWidth * 0.4,
                height: cons.maxHeight * 0.425,
                child: Column(
                  children: [
                    Container(
                      width: cons.maxWidth * 0.2,
                      height: 40,

                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: bdRadius),
                      child: Center(
                        child: Text(
                          title,
                          style: TextStyle(
                              fontSize: 18.0,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    Expanded(child: child ?? Container()),
                  ],
                ),
              ),
            ),
          );
      return SizedBox(
        width: cons.maxWidth,
        height: cons.maxHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  cardView(
                      'Solar Heating Unit',
                      DashboardScreenHeatingUnitConsumer(
                        width: cons.maxWidth,
                        height: cons.maxHeight,
                      )),
                  cardView(
                      'Environment Meter',
                      DashboardScreenEnvironmentMeterConsumer(
                        width: cons.maxWidth,
                        height: cons.maxHeight,
                      )),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  cardView(
                      'Shed Meter',
                      DashboardScreenHeatingUnitConsumer(
                        width: cons.maxWidth,
                        height: cons.maxHeight,
                      )),
                  cardView(
                      'Energy Meter',
                      DashboardScreenEnvironmentMeterConsumer(
                        width: cons.maxWidth,
                        height: cons.maxHeight,
                      )),
                ],
              ),
            ),
            // Expanded(
            //     flex: 1,
            //     child: Padding(
            //       padding: EdgeInsets.all(cons.maxHeight * 0.05),
            //       child: cardView(
            //         'Power Unit',
            //         DashboardScreenPowerUnitConsumer(
            //           width: cons.maxWidth,
            //           height: cons.maxHeight,
            //         ),
            //       ),
            //     )),
          ],
        ),
      );
    });
  }
}
