import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../providers/login_user_data.dart';

class NavBarPlane extends StatefulWidget {
  const NavBarPlane(
      {Key? key, required this.switchPage, required this.pageTitle})
      : super(key: key);
  final PageTitle pageTitle;
  final Function switchPage;

  @override
  State<NavBarPlane> createState() => _NavBarPlaneState();
}

class _NavBarPlaneState extends State<NavBarPlane> {
  @override
  void initState() {
    super.initState();
    _activePage = widget.pageTitle;
  }

  PageTitle? _activePage;

  Widget _planeItem(PageTitle page, IconData icon) {
    const activeClr = Colors.lightGreenAccent;
    const inactiveClr = Colors.white;
    return GestureDetector(
        onTap: () {
          setState(() {
            _activePage = page;
          });

          widget.switchPage(page, HomeScreen.pageTitle(page));
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          height: MediaQuery.of(context).size.height * 0.1,
          width: double.infinity,
          color: Theme.of(context).colorScheme.secondary,
          margin: const EdgeInsets.only(bottom: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: _activePage == page ? activeClr : inactiveClr,
              ),
              Text(
                // 'k',
                HomeScreen.pageTitle(page),
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  // fontSize: 1,
                  color: _activePage == page ? activeClr : inactiveClr,
                ),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<PageTitle, IconData>> planeData = [
      {PageTitle.dashboard: Icons.dashboard},
      {PageTitle.solarHeaterMeter: Icons.heat_pump},
      {PageTitle.flowMeter: Icons.water_drop},
      {PageTitle.ductMeter: Icons.credit_card},
      {PageTitle.ambientMeter: Icons.device_thermostat},
      {PageTitle.shedMeter: Icons.home},
      {PageTitle.electricalEnergyMeter: Icons.electric_bolt},
      {PageTitle.thermalEnergyMeter: Icons.electric_meter},
      {PageTitle.firewoodMoisture: Icons.water_drop},
      {PageTitle.profile: Icons.settings}
    ];
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white70,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${LoginUserData.getLoggedUser!.firstname[0]} ',
                    style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ),
            accountName: Text(
                "${LoginUserData.getLoggedUser!.firstname} ${LoginUserData.getLoggedUser!.lastname}"),
            accountEmail: Text(LoginUserData.getLoggedUser!.email),
          ),
          ...planeData
              .map((e) => _planeItem(e.keys.first, e.values.first))
              .toList()
        ],
      ),
    );
  }
}
