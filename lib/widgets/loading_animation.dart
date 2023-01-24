import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MyLoadingAnimation extends StatelessWidget {
  const MyLoadingAnimation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.25),
      child: Center(
        child: LoadingAnimationWidget.fourRotatingDots(
            color: Theme.of(context).colorScheme.secondary, size: 100),
      ),
    );
  }
}
