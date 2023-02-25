import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/firebase_auth.dart';
import '../models/user.dart';
import '../widgets/auth_screen_form.dart';
import '../helpers/custom_data.dart';
import '../widgets/custom_check_box.dart';
import '../widgets/loading_animation.dart';
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
  var _initAutoLogin = true;
  var _authMode = AuthMode.login;
  bool goodConnection = false;

  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
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

  Future<void> tryAutoLogin() async {
    if (_initAutoLogin && !_isLoading) {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(RememberMeBnState.rememberMePrefName)) {
        _initAutoLogin = false;
        setState(() {
          _isLoading = true;
        });
        final userData = User.fromLoginMap(
            json.decode(prefs.getString(RememberMeBnState.rememberMePrefName)!)
            as Map<String, dynamic>);
        if (goodConnection) {
          _performLogin(userData, true);
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
        if (mounted && goodConnection) {
          if (message.startsWith("Welcome")) {
            _initAutoLogin = false;
            Future.delayed(Duration.zero).then((_) {
              Navigator.pushReplacementNamed(context, HomeScreen.routeName);
            });
          } else {
            setState(() {
              _isLoading = false;
            });
            if(message.contains("has expired")){
              message='Please check your internet connection to the broker';
            }
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
    _initAutoLogin = false;
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
    goodConnection = _connectionStatus == ConnectivityResult.ethernet ||
        _connectionStatus == ConnectivityResult.mobile ||
        _connectionStatus == ConnectivityResult.wifi;

    if (!goodConnection) {
      _initAutoLogin = true;
      setState(() {
        _isLoading = false;
      });
    } else {
      tryAutoLogin();
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: LayoutBuilder(
          builder: (context, cons) => Stack(
            children: [
              Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Theme.of(context).colorScheme.secondary ,

                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child:
                  Center(child: Padding(

                    padding: const EdgeInsets.all(8.0),
                    child: AuthScreenForm(
                      authMode: _authMode,
                      isLoading: _isLoading,
                      submit: _submit,
                      switchAuthMode: _switchAuthMode,
                      isOffline: !goodConnection,
                    ),
                  ),)
              ),
              Visibility(
                visible: _isLoading,
                child: const MyLoadingAnimation(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
