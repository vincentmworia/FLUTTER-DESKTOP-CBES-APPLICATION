import 'package:flutter/material.dart';

class ShedMeterScreen extends StatelessWidget {
  const ShedMeterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("""
     Shed Meter
     - Shed Temperature
     - Shed Irradiance
      """),
    );
  }
}
