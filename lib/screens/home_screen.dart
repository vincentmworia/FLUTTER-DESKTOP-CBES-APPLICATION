import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../providers/login_user_data.dart';
import './auth_screen.dart';
import '../widgets/nav_bar_plane.dart';
import './dashboard_screen.dart';
import './administrator_screen.dart';
import './solar_heater_screen.dart';
import './profile_screen.dart';
import './electrical_energy_screen.dart';
import './ambient_meter_screen.dart';
import './flow_meter_screen.dart';
import './thermal_energy_screen.dart';
import './shed_meter_screen.dart';
import './duct_meter_screen.dart';
import './firewood_moisture_screen.dart';

enum PageTitle {
  dashboard,
  solarHeaterMeter,
  flowMeter,
  ambientMeter,
  shedMeter,
  ductMeter,
  electricalEnergyMeter,
  thermalEnergyMeter,
  admin,
  profile,
  firewoodMoisture
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/home_screen';

  // todo Add Firewood Moisture Meter Dashboard to feed in moisture data
  // todo request for the moisture meter API

  static String pageTitle(PageTitle page) {
    switch (page) {
      case PageTitle.dashboard:
        return "Dashboard";
      case PageTitle.solarHeaterMeter:
        return "Solar Heater";
      case PageTitle.ambientMeter:
        return "Ambient Meter";
      case PageTitle.electricalEnergyMeter:
        return "Electrical Energy";
      case PageTitle.admin:
        return "Administrator";
      case PageTitle.profile:
        return "My Profile";
      case PageTitle.flowMeter:
        return "Flow Meter";
      case PageTitle.shedMeter:
        return "Shed Meter";
      case PageTitle.ductMeter:
        return "Duct Meter";
      case PageTitle.thermalEnergyMeter:
        return "Thermal Energy";
      case PageTitle.firewoodMoisture:
        return "Wood Moisture";
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageTitle _page = PageTitle.dashboard;
  String _pageTitle = 'Dashboard';
  var _deCompressNavPlane = true;
  var _showNavPlane = false;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    try {
      Future.delayed(Duration.zero)
          .then((value) async => await _connectivity.checkConnectivity())
          .then((value) => setState(() {}));

      ConnectivityResult? prevResult;
      _connectivity.onConnectivityChanged.listen((result) async {
        if (prevResult != result && mounted) {
          Navigator.pushReplacementNamed(context, AuthScreen.routeName);
        }
      });
    } on PlatformException catch (_) {}
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription?.cancel();
  }

  void _switchPage(PageTitle page, String title) {
    setState(() {
      // todo
      _showNavPlane = false;
      _deCompressNavPlane = true;
      _page = page;
      _pageTitle = title;
    });
  }

  Widget _pageWidget(PageTitle page) {
    switch (page) {
      case PageTitle.dashboard:
        return DashboardScreen(switchDashboardPage: _switchPage);
      case PageTitle.solarHeaterMeter:
        return const HeatingUnitScreen();
      case PageTitle.ambientMeter:
        return const AmbientMeterScreen();
      case PageTitle.electricalEnergyMeter:
        return const ElectricalEnergyScreen();
      case PageTitle.admin:
        return const AdministratorScreen();
      case PageTitle.profile:
        return const ProfileScreen();
      case PageTitle.flowMeter:
        return const FlowMeterScreen();
      case PageTitle.shedMeter:
        return const ShedMeterScreen();
      case PageTitle.ductMeter:
        return const DuctMeterScreen();
      case PageTitle.thermalEnergyMeter:
        return const ThermalEnergyScreen();
      case PageTitle.firewoodMoisture:
        return const FirewoodMoistureScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    // todo SHOULD BE TRIGGERED ONCE
    // TODO DECOMPRESSING THE NAVBAR THROWING ERROR IF MILLISECONDS IS INCREASED
    const duration = Duration(milliseconds: 20);

    const txtStyle = TextStyle(
        color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 3.0);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: AnimatedContainer(
            duration: duration,
            child: Padding(
                padding: EdgeInsets.only(left: _deCompressNavPlane ? 20 : 60),
                child: Text(_pageTitle)),
          ),
          actions: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onDoubleTap: () {
                          _switchPage(PageTitle.dashboard,
                              HomeScreen.pageTitle(PageTitle.dashboard));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            'images/cbes_logo_cropped.PNG',
                            fit: BoxFit.cover,
                            width: 40,
                            // height: 50,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'DeKUT\tCBES',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 20.0,
                            letterSpacing: 1.0),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 25),
                        child: Text(
                          '${LoginUserData.getLoggedUser!.firstname} ${LoginUserData.getLoggedUser!.lastname}',
                          overflow: TextOverflow.clip,
                          style: txtStyle,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
          leading: Padding(
            padding: const EdgeInsets.only(left: 25),
            child: IconButton(
              disabledColor: Colors.white,
              color: Colors.white,
              hoverColor: Theme.of(context).colorScheme.primary,
              focusColor: Theme.of(context).colorScheme.primary,
              onPressed: () async {
                if (_deCompressNavPlane) {
                  setState(() {
                    _showNavPlane = false;
                    _deCompressNavPlane = !_deCompressNavPlane;
                  });
                  Future.delayed(duration).then((value) => setState(() {
                        _showNavPlane = true;
                      }));
                } else {
                  setState(() {
                    _showNavPlane = false;
                    _deCompressNavPlane = !_deCompressNavPlane;
                  });
                }
              },
              icon: Icon(_deCompressNavPlane ? Icons.menu : Icons.arrow_back),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        // backgroundColor: Theme.of(context).colorScheme.secondary ,
        body: Row(
          children: [
            AnimatedContainer(
              duration: duration,
              width: _deCompressNavPlane ? 0 : 130,
              height: double.infinity,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.99),
              child: Visibility(
                visible: _showNavPlane,
                child: NavBarPlane(
                  switchPage: _switchPage,
                  pageTitle: _page,
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: _pageWidget(_page),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
