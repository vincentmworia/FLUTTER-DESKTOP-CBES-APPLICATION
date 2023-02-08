import 'package:flutter/material.dart';

class FirewoodMoistureDetailedScreen extends StatelessWidget {
  const FirewoodMoistureDetailedScreen(
      {Key? key,
      required this.op,
      required this.pageData,
      required this.cancelPage})
      : super(key: key);
  final double op;
  final Map<String, dynamic> pageData;
  final Function cancelPage;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: op,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Stack(
            children: [
              Center(
                child: Text(pageData.toString()),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: IconButton(
                  iconSize: 30.0,
                  icon: Icon(
                    Icons.cancel,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () async => await cancelPage(),
                ),
              ),
            ],
          ),
        ));
  }
}
