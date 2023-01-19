import 'package:datetime_picker_formfield_new/datetime_picker_formfield_new.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class SearchToggleView extends StatefulWidget {
  const SearchToggleView({Key? key, required this.toggleOnlineStatus, required this.generateExcel})
      : super(key: key);

  final Function toggleOnlineStatus;
  final Function generateExcel;

  @override
  State<SearchToggleView> createState() => _SearchToggleViewState();
}

class _SearchToggleViewState extends State<SearchToggleView> {
  var _online = true;

  // todo Break into a separate widget named SearchDateTime or rather this whole widget???
  Widget _searchDateTime({required String title}) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: const EdgeInsets.only(top: 12, right: 6),
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              )),
          SizedBox(
              width: MediaQuery.of(context).size.width <= 170
                  ? 170
                  : MediaQuery.of(context).size.width * 0.125,
              child: DateTimeField(
                format: DateFormat("yyyy-MM-dd HH:mm"),
                onShowPicker: (context, currentValue) async {
                  final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
                  if (date != null) {
                    TimeOfDay? time;
                    Future.delayed(Duration.zero).then((value) async {
                      time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                    });
                    return DateTimeField.combine(date, time);
                  } else {
                    return currentValue;
                  }
                },
              ))
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: !_online ? 50 : 0,
            child: _online
                ? null
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _searchDateTime(title: 'From:\t'),
                      _searchDateTime(title: 'To:\t'),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.primary,
                            size: 30,
                          )),
                    ],
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                  icon: const Icon(Icons.file_copy),
                  onPressed: ()=>widget.generateExcel(),
                  label: const Text('Generate Excel Sheet')),
              // todo Generate PDF???
              // ElevatedButton.icon(
              //     icon: const Icon(Icons.picture_as_pdf),
              //     onPressed: () {},
              //     label: const Text('Generate PDF')),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(_online ? 'Online\t' : 'Offline',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          letterSpacing: 3.0,
                          color: Theme.of(context).colorScheme.primary)),
                  Switch.adaptive(
                      value: _online,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (val) {
                        setState(() {
                          widget.toggleOnlineStatus(val);
                          _online = val;
                        });
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
