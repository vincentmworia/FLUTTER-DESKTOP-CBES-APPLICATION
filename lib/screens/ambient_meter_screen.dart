import 'package:flutter/material.dart';

class AmbientMeterScreen extends StatelessWidget {
  const AmbientMeterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("""
    Ambient Meter
    - Ambient Temperature
    - Ambient Irradiance
      """),
    );
  }
}
