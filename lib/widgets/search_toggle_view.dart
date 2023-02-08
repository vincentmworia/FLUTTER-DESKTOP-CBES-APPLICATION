import 'package:datetime_picker_formfield_new/datetime_picker_formfield_new.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchToggleView extends StatefulWidget {
  const SearchToggleView({
    Key? key,
    required this.toggleOnlineStatus,
    required this.generateExcel,
    required this.fromController,
    required this.toController,
    required this.searchDatabase,
    required this.activateExcel,
    //todo
    required this.formKey,
  }) : super(key: key);

  final Function? toggleOnlineStatus;
  final Function generateExcel;
  final bool activateExcel;
  final Function? searchDatabase;
  final TextEditingController fromController;
  final TextEditingController toController;

  final GlobalKey<FormState> formKey;

  static DateTime? fromDateVal;
  static DateTime? toDateVal;

  @override
  State<SearchToggleView> createState() => _SearchToggleViewState();
}

class _SearchToggleViewState extends State<SearchToggleView> {
  var _online = true;
  var _visibility = false;
  DateTime? _tempFromDate;
  // final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // todo Put a better date format

  // todo Break into a separate widget named SearchDateTime or rather this whole widget???
  Widget _searchDateTime(
          {required String title, required TextEditingController controller}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (title.contains('From') ||
              (title.contains('To') && widget.fromController.text != ""))
            Container(
                margin: const EdgeInsets.only(top: 12, right: 6),
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                )),
          // todo Work on this UI, Showing the from and to, and their lengths
          if (title.contains('From') ||
              (title.contains('To') && widget.fromController.text != ""))
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: DateTimeField(
                  format: DateFormat("yyyy-MM-dd HH:mm"),
                  // format: DateFormat("EEE, MMM d yyyy h:mm a"),
                  controller: controller,

                  // onFieldSubmitted: (value) {
                  // },
                  // validator: ,
                  // cursorRadius: Radius.circular(200),

                  showCursor: true,
                  validator: (value) {
                    if (value == null) {
                      return "Select Date and Time";
                    }
                    if (SearchToggleView.fromDateVal!
                        .isAfter(SearchToggleView.toDateVal!)) {
                      return "Select Date and Time";
                    }
                    return null;
                  },

                  onShowPicker: (context, currentValue) async {
                    final currentTime = DateTime.now();
                    final date = await showDatePicker(
                        context: context,
                        firstDate: title.contains('To')
                            ? _tempFromDate!
                            : DateTime(2023, 1, 10, 0, 0),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(
                          currentTime.year,
                          currentTime.month,
                          currentTime.day,
                          currentTime.hour,
                          currentTime.minute,
                        ));
                    if (date != null) {
                      TimeOfDay? time;
                      await Future.delayed(Duration.zero)
                          .then((value) async => time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                    currentValue ?? DateTime.now()),
                              ));

                      final dateTimeSelected =
                          DateTimeField.combine(date, time);
                      if (title.contains("From")) {
                        _tempFromDate = dateTimeSelected;
                        SearchToggleView.fromDateVal = dateTimeSelected;
                        widget.fromController.text =
                            DateFormat("EEE, MMM d yyyy h:mm a")
                                .format(dateTimeSelected);
                      }
                      if (title.contains("To")) {
                        SearchToggleView.toDateVal = dateTimeSelected;
                        widget.toController.text =
                            DateFormat("EEE, MMM d yyyy h:mm a")
                                .format(dateTimeSelected);
                      }

                      // return dateTimeSelected;
                    } else {
                      // return currentValue;
                    }
                    setState(() {});
                    return null;
                  },
                ))
        ],
      );

  @override
  Widget build(BuildContext context) {
    if (widget.toggleOnlineStatus == null) {
      _visibility = true;
      _online = false;
    }
    print(_visibility);
    print(!(!_online || widget.toggleOnlineStatus != null));
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: !_online || widget.toggleOnlineStatus == null
                ? (MediaQuery.of(context).size.height * 0.2 <= 112
                    ? 112
                    : MediaQuery.of(context).size.height * 0.2)
                : 0,
            child: _online
                ? null
                : Visibility(
                    visible: _visibility,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _searchDateTime(
                                title: 'From:\t',
                                controller: widget.fromController),
                            _searchDateTime(
                                title: 'To:\t',
                                controller: widget.toController),
                          ],
                        ),
                        IconButton(
                            onPressed: widget.fromController.text != "" &&
                                    widget.toController.text != "" &&
                                    SearchToggleView.fromDateVal!
                                        .isBefore(SearchToggleView.toDateVal!)
                                ?  () {
                                    widget.searchDatabase!();
                                  }:null,
                            icon: Icon(
                              Icons.search,
                              color: widget.fromController.text != "" &&
                                      widget.toController.text != "" &&
                                      SearchToggleView.fromDateVal!
                                          .isBefore(SearchToggleView.toDateVal!)
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                              size: 30,
                            )),
                      ],
                    ),
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                  icon: const Icon(Icons.file_copy),
                  onPressed: !(widget.activateExcel)
                      ? null
                      : () => widget.generateExcel(),
                  label: const Text('Generate Excel Sheet')),
              if (widget.toggleOnlineStatus != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_online ? 'Online\t' : 'Offline',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                letterSpacing: 3.0,
                                color: Theme.of(context).colorScheme.primary)),
                    Switch.adaptive(
                        value: _online,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (val) async {
                          setState(() {
                            _visibility = false;
                            widget.toggleOnlineStatus!(val);
                            _online = val;
                          });
                          if (val == false) {
                            await Future.delayed(
                                const Duration(milliseconds: 500));

                            setState(() {
                              _visibility = true;
                            });
                          }
                        }),
                  ],
                )
            ],
          ),
        ],
      ),
    );
  }
}
