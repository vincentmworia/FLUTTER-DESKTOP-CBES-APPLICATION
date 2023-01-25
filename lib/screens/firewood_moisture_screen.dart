import 'package:flutter/material.dart';

class FirewoodMoistureScreen extends StatelessWidget {
  const FirewoodMoistureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("""
     Firewood Moisture 
     - Date 
     - Stack Number
     - Moisture Value
     
     - Graph of historical data?
     - List of all moisture data
     
     - Search moisture for particular stack number
     - CRUD Stack number, and the data contents
      
     - Generate excel
      """),
    );
  }
}
