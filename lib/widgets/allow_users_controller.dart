import 'package:cbesdesktop/models/logged_in.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class AdminAllowUsers extends StatefulWidget {
  const AdminAllowUsers(this.allowUsers, {Key? key}) : super(key: key);

  final List<LoggedIn> allowUsers;

  @override
  State<AdminAllowUsers> createState() => _AdminAllowUsersState();
}

class _AdminAllowUsersState extends State<AdminAllowUsers> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 200, viewportFraction: 0.83);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  Widget _buildRow(String title, String data) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          // Custom.normalTextOrange('$title:'),
          Text(
            data,
            style: const TextStyle(
              color: Colors.white,
              overflow: TextOverflow.ellipsis,
              fontSize: 18.0,
            ),
          ),
        ],
      );

  Widget _buildWidgets(BuildContext context, int index, double deviceHeight) {
    LoggedIn user = widget.allowUsers[index];
    return AnimatedBuilder(
      animation: _pageController,
      builder: (BuildContext ctx, Widget? widget) {
        var value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }
        return Center(
            child: SizedBox(
          height: Curves.easeInOut.transform(value) * deviceHeight / 3.5,
          child: widget,
        ));
      },
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: MyApp.appPrimaryColor,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  )
                ]),
            child: LayoutBuilder(builder: (context, constraints) {
              List<Map<String, String>> allowUserData = [
                {'title': 'Email', 'data': user.email},
                {'title': 'Firstname', 'data': user.firstname},
                {'title': 'Lastname', 'data': user.lastname},
              ];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: allowUserData
                          .map((Map<String, String> usrData) => _buildRow(
                              usrData['title'] as String,
                              usrData['data'] as String))
                          .toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyApp.appSecondaryColor,
                          ),
                          child: IconButton(
                            onPressed: () =>
                                _allowUsersFunction(context, index, false),
                            icon: const Icon(Icons.remove, color: Colors.white),
                          ),
                        ),
                        const Text('ACTIVATE'),
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: IconButton(
                            onPressed: () =>
                                _allowUsersFunction(context, index, true),
                            icon: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _allowUsersFunction(
      BuildContext context, int index, bool operation) async {
    LoggedIn user = widget.allowUsers[index];
    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: Text(
                  'Do you want to ${operation ? 'add' : 'remove'} ${user.email} ${operation ? 'to' : 'from'} the application'),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: MyApp.appSecondaryColor),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('No')),
                    ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);

                          // todo widget.allowUser(operation == true ? 1 : 0, user);
                        },
                        child: const Text('Yes')),
                  ],
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
          child: Text('Grant access'),
        ),
        SizedBox(
          height: deviceHeight / 3.5,
          child: PageView.builder(
              controller: _pageController,
              itemCount: widget.allowUsers.length,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemBuilder: ((BuildContext ctx, i) =>
                  _buildWidgets(ctx, i, deviceHeight))),
        )
      ],
    );
  }
}
