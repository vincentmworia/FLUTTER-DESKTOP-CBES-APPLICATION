import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomCheckBox extends StatefulWidget {
  const CustomCheckBox({Key? key}) : super(key: key);

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  var checkValue = false;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
        fillColor: checkValue
            ? null
            : MaterialStateColor.resolveWith(
                (_) => Theme.of(context).colorScheme.secondary),
        value: checkValue,
        activeColor: Theme.of(context).colorScheme.primary,
        onChanged: (newVal) {
          setState(() {
            Provider.of<RememberMeBnState>(context, listen: false)
                .setBnState(newVal!);
            checkValue = newVal;
          });
        });
  }
}

class RememberMeBnState with ChangeNotifier {
  // var _bnState = false;

  // bool get bnState => _bnState;
  static const rememberMePrefName = 'autoLogUser';
  static bool? bnState;

  void setBnState(bool buttonState) {
    bnState = buttonState;
    notifyListeners();
  }
}
