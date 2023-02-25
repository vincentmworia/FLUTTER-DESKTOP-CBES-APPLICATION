import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './auth_screen.dart';
import '../widgets/nav_bar_plane.dart';
import './dashboard_screen.dart';
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
  profile,
  firewoodMoisture
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/home_screen';

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
          .then((value) async => await _connectivity.checkConnectivity());

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
      _page = page;
      _pageTitle = title;
      if (_page == PageTitle.dashboard) {
        _showNavPlane = false;
        _deCompressNavPlane = true;
      }
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
        return const FirewoodMoistureScreen(
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 20);
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          child: NavBarPlane(
            switchPage: _switchPage,
            pageTitle: _page,
          ),
        ),
        appBar: AppBar(
          title: Text(_pageTitle),
        ),
        backgroundColor: Colors.white,
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
