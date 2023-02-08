import 'package:flutter/material.dart';

class FirewoodMoistureSearchAndAddStack extends StatelessWidget {
  const FirewoodMoistureSearchAndAddStack({Key? key, required this.searchController, required this.stackNameController, required this.resetSearchController, required this.refreshPage, required this.addStackBnPressed}) : super(key: key);

  final TextEditingController searchController;
  final TextEditingController stackNameController;
  final Function resetSearchController;
  final Function refreshPage;
  final Function addStackBnPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) => refreshPage,
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
                            child: TextField(
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
