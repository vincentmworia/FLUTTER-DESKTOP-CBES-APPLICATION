import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/firebase_auth.dart';
import '../models/user.dart';
import '../widgets/auth_screen_form.dart';
import '../helpers/custom_data.dart';
import '../widgets/custom_check_box.dart';
import './home_screen.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static const routeName = '/auth_screen';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLoading = false;
  var init = true;
  var _authMode = AuthMode.login;

  ConnectivityResult _connectionStatus = ConnectivityResult.ethernet;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // todo Check whether autologin is activated,
    //  todo if so, directly move to the dashboard screen

    try {
      Future.delayed(Duration.zero)
          .then((value) async => await _connectivity.checkConnectivity())
          .then((value) => setState(() {
                _connectionStatus = value;
              }));
    } on PlatformException catch (_) {
      return;
    }
    ConnectivityResult? tempResult;
    _connectivity.onConnectivityChanged.listen((result) {
      tempResult ??= result;
      if (tempResult != result) {
        if (result == ConnectionState.none) {}
        _rebuildScreen(result);
        tempResult = result;
      }
    });
  }

  // @override
  // Future<void> didChangeDependencies() async {
  //   super.didChangeDependencies();
  //   tryAutoLogin();
  // }

  var workOnce=true;
  Future<void> tryAutoLogin() async {
    if (init) {
      // print('pref');
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(RememberMeBnState.rememberMePrefName)) {
        if(workOnce){
          workOnce=false;
          setState(() {
            _isLoading = true;
          });
          // todo To be triggered once!!!
          print('contains');
          final userData = User.fromLoginMap(
              json.decode(prefs.getString(RememberMeBnState.rememberMePrefName)!)
              as Map<String, dynamic>);
          _performLogin(userData, true);

          workOnce =true;
          init = false;

        }
      }
    }
  }

  void _rebuildScreen(ConnectivityResult result) {
    if (mounted) {
      setState(() {
        _connectionStatus = result;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription?.cancel();
  }

  void _switchAuthMode(AuthMode authMode) {
    setState(() {
      _authMode = authMode;
    });
  }

  void _performLogin(User user, [bool autoLog = false]) {
    try {
      Future.delayed(Duration.zero).then((value) async =>
          await FirebaseAuthentication.signIn(user, context)
              .then((message) async {
            // setState(() {
            //   _isLoading = false;
            // });
            if (mounted) {
              if (message.startsWith("Welcome")) {
                Future.delayed(Duration.zero).then((_) {
                  Navigator.pushReplacementNamed(context, HomeScreen.routeName);
                });
              } else {
                await customDialog(context, message);
              }
            }
          }));
    } catch (e) {
      Future.delayed(Duration.zero)
          .then((value) async => await customDialog(context, 'Login Failed'));
    }
  }

  void _submit(User user) async {
    setState(() {
      _isLoading = true;
    });
    if (_authMode == AuthMode.register) {
      try {
        await FirebaseAuthentication.signUp(user)
            .then((message) async => await customDialog(context, message))
            .then((_) => setState(() {
                  _isLoading = false;
                }));
      } catch (e) {
        await customDialog(context, 'Signing Up Failed');
      }
    }
    if (_authMode == AuthMode.login) {
      _performLogin(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building');
    // todo make sure that the try auto login occurs only once when there is internet connection
    // todo, after a disconnection, do re-autologin
    // IMPORTANT
    tryAutoLogin();
    if (_connectionStatus == ConnectivityResult.none) {
      setState(() {
        _isLoading = false;
      });
    }
    const borderRadius = 15.0;

    final goodConnection = _connectionStatus == ConnectivityResult.ethernet ||
        _connectionStatus == ConnectivityResult.mobile ||
        _connectionStatus == ConnectivityResult.wifi;

    if (!goodConnection) {
      init = true;
    }
    final deviceWidth = MediaQuery.of(context).size.width;

    final bgImage = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Theme.of(context).colorScheme.primary.withOpacity(0.25),
            // Theme.of(context).colorScheme.secondary ,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );

    const bdRadius = BorderRadius.only(
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, cons) => Stack(
            children: [
              bgImage,
              Align(
                alignment: Alignment.center,
                child: Card(
                  elevation: 20,
                  shape: const RoundedRectangleBorder(borderRadius: bdRadius),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: deviceWidth < 1200
                        ? deviceWidth * 0.55
                        : deviceWidth * 0.45,
                    height: _authMode == AuthMode.register ? 1200 : 550,
                    decoration: BoxDecoration(
                        color: _isLoading
                            ? Colors.white.withOpacity(0.4)
                            : Colors.white,
                        borderRadius: bdRadius),
                    padding: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AuthScreenForm(
                          authMode: _authMode,
                          isLoading: _isLoading,
                          submit: _submit,
                          switchAuthMode: _switchAuthMode),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _isLoading,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.25),
                  child: Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                        color: Theme.of(context).colorScheme.secondary,
                        size: 100),
                  ),
                ),
              ),
              //todo  transition from offline to online: try autologin
              if (!goodConnection)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'images/cbes_logo_main.PNG',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "No Internet",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.7),
                              letterSpacing: 10,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    // child: Text(
                    //   "OFFLINE",
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //       color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    //       letterSpacing:
                    //           MediaQuery.of(context).size.width * 0.035,
                    //       fontSize: MediaQuery.of(context).size.width * 0.075,
                    //       fontWeight: FontWeight.bold),
                    // ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
