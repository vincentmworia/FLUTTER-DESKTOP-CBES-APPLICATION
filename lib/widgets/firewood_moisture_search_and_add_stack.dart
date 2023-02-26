import 'package:datetime_picker_formfield_new/datetime_picker_formfield_new.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FirewoodMoistureSearchAndAddStack extends StatelessWidget {
  const FirewoodMoistureSearchAndAddStack(
      {Key? key,
      required this.searchController,
      required this.stackNameController,
      required this.resetSearchController,
      required this.refreshPage,
      required this.addStackBnPressed,
      required this.searchDateTimeController,
      required this.searchMoistureLevelController,
      required this.searchSelectedDate, required this.cons})
      : super(key: key);

  final TextEditingController searchController;
  final TextEditingController searchDateTimeController;
  final TextEditingController searchMoistureLevelController;
  final TextEditingController stackNameController;
  final Function searchSelectedDate;
  final Function resetSearchController;
  final Function refreshPage;
  final Function addStackBnPressed;
final BoxConstraints cons;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) => refreshPage(),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(width: 0.8),
                ),
                hintText: 'Search Stack by Id',
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      onPressed: () => resetSearchController(),
                      icon: const Icon(
                        Icons.clear,
                        size: 30,
                      )),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          content: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height:400,
                              width: 400,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      "Add New Stack",
                                      style: TextStyle(
                                          color:
                                          Theme.of(context).colorScheme.primary,
                                          fontSize: 25),
                                    ),
                                  ),
                                  const SizedBox(height: 20,),
                                  TextField(
                                    controller: stackNameController,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(width: 0.8),
                                      ),
                                      hintText: 'Enter Stack ID',
                                    ),
                                  ),

                                  const SizedBox(height: 40),
                                  DateTimeField(
                                    format: DateFormat("yyyy-MM-dd HH:mm"),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(20),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide:
                                              const BorderSide(width: 0.8),
                                        ),
                                        hintText: 'Select Date and Time',
                                        counterText: "Date and Time"),
                                    controller: searchDateTimeController,
                                    showCursor: true,
                                    validator: (value) {
                                      if (value == null) {
                                        return "Select Date and Time";
                                      }
                                      return null;
                                    },


                                    onShowPicker: (context, currentValue) async {
                                      final currentTime = DateTime.now();
                                      final date = await showDatePicker(
                                          context: context,
                                          firstDate: DateTime(2023, 1, 10, 0, 0),
                                          initialDate:
                                              currentValue ?? DateTime.now(),
                                          lastDate: DateTime(
                                            currentTime.year,
                                            currentTime.month,
                                            currentTime.day,
                                            currentTime.hour,
                                            currentTime.minute,
                                          ));
                                      if (date != null) {
                                        TimeOfDay? time;
                                        await Future.delayed(Duration.zero).then(
                                            (value) async =>
                                                time = await showTimePicker(
                                                  context: context,
                                                  initialTime:
                                                      TimeOfDay.fromDateTime(
                                                          currentValue ??
                                                              DateTime.now()),
                                                ));

                                        final dateTimeSelected =
                                            DateTimeField.combine(date, time);

                                        searchDateTimeController.text =
                                            DateFormat("EEE, MMM d yyyy h:mm a")
                                                .format(dateTimeSelected);

                                        searchSelectedDate(
                                            DateFormat("yyyy-MM-dd HH:mm")
                                                .format(dateTimeSelected));
                                        return null;
                                      } else {
                                        return currentValue;
                                      }
                                    },
                                  ),

                                  const SizedBox(height: 20),
                                  TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(width: 0.8),
                                      ),
                                      hintText: 'Enter Moisture Level',
                                      counterText: 'Moisture Level',
                                    ),
                                    controller: searchMoistureLevelController,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                                onPressed: () async =>
                                    await addStackBnPressed(ctx),
                                child: const Text('Ok'))
                          ],
                        ));
              },
              label: const Text('Add Stack')),
        )
      ],
    );
  }
}
