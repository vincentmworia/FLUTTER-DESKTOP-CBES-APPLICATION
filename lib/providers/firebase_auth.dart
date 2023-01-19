import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/signIn.dart';
import '../models/logged_in.dart';
import '../models/user.dart';
import '../private_data.dart';
import '../models/signUp.dart';
import '../screens/auth_screen.dart';
import '../widgets/custom_check_box.dart';
import './login_user_data.dart';
import './mqtt.dart';

class FirebaseAuthentication {
  static Uri _actionEndpointUrl(String action) => Uri.parse(
      "https://identitytoolkit.googleapis.com/v1/accounts:${action}key=$firebaseApiKey");

  static String _getErrorMessage(String errorTitle) {
    var message = 'Operation failed';

    if (errorTitle.contains('EMAIL_EXISTS')) {
      message = 'Email is already in use';
    }
    if (errorTitle.contains('CREDENTIAL_TOO_OLD_LOGIN_AGAIN')) {
      message = 'Select a new email';
    } else if (errorTitle.contains('INVALID_EMAIL')) {
      message = 'This is not a valid email address';
    } else if (errorTitle.contains('NOT_ALLOWED')) {
      message = 'User needs to be allowed by the admin';
    } else if (errorTitle.contains('TOO_MANY_ATTEMPTS_TRY_LATER:')) {
      message =
          'We have blocked all requests from this device due to unusual activity. Try again later.';
    } else if (errorTitle.contains('EMAIL_NOT_FOUND')) {
      message = 'Could not find a user with that email.';
    } else if (errorTitle.contains('WEAK_PASSWORD')) {
      message = 'Password must be at least 6 characters';
    } else if (errorTitle.contains('INVALID_PASSWORD')) {
      message = 'Invalid password';
    } else {
      message = message;
    }
    return message;
  }

  static Future<String> signUp(User user) async {
    String? message;
    try {
      final response = await http.post(_actionEndpointUrl("signUp?"),
          body: json.encode({
            "email": user.email!,
            "password": user.password!,
            "returnSecureToken": true,
          }));
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['error'] != null) {
        message = _getErrorMessage(responseData['error']['message']);
        return message;
      }
      final signedUpUser = SignUp.fromMap(responseData);
      user.localId = signedUpUser.localId;
      user.allowed = allowUserFalse;
      user.privilege = userGuest;

      await http.patch(
          Uri.parse('$firebaseDbUrl/users.json?auth=${signedUpUser.idToken}'),
          body: json.encode({
            signedUpUser.localId: user.toMap(),
          }));
      message = 'Registered,\n${user.firstName} ${user.lastName}';
    } catch (e) {
      message = e.toString();
      return message;
    }
    return message;
  }

  static Future<String> signIn(User user, BuildContext context) async {
    String? message;
    http.Response? response;
    try {
      response = await http.post(_actionEndpointUrl("signInWithPassword?"),
          body: json.encode({
            "email": user.email!,
            "password": user.password!,
            "returnSecureToken": true,
          }));
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['error'] != null) {
        message = _getErrorMessage(responseData['error']['message']);
        return message;
      }

      final signedInUser = SignIn.fromMap(responseData);
      final dbResponse = await http.get(Uri.parse(
          '$firebaseDbUrl/users/${signedInUser.localId}.json?auth=${signedInUser.idToken}'));
      final loggedIn = LoggedIn.fromMap(json.decode(dbResponse.body));
      message = await Future.delayed(Duration.zero).then((_) {
        Provider.of<LoginUserData>(context, listen: false)
            .setLoggedInUser(loggedIn);
        if (loggedIn.allowed != allowUserTrue) {
          return false;
        }
        return true;
      }).then((loginMqtt) async {
        if (loginMqtt) {
          await Provider.of<MqttProvider>(context, listen: false)
              .initializeMqttClient();
          message = 'Welcome,\n${loggedIn.firstname} ${loggedIn.lastname}';
          return message;
        } else {
          message = '${loggedIn.email} is not authorized  by the admin';
          return message;
        }
      });
    } catch (e) {
      message = e.toString();
      if (message != null &&
          (message!.contains('identity') ||
              message!.contains('Connection closed before full'))) {
        message = 'Please check your internet connection';
      }
      return message ?? 'Login error';
    }
    return message!;
  }

  static Future<void> logout(BuildContext context) async {
    final client = Provider.of<MqttProvider>(context, listen: false);
    Provider.of<LoginUserData>(context, listen: false).resetLoggedInUser();

    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(RememberMeBnState.rememberMePrefName)) {
      prefs.remove(RememberMeBnState.rememberMePrefName);
    }
    Future.delayed(Duration.zero)
        .then((_) {
          if (client.connectionStatus == ConnectionStatus.connected &&
              client.disconnectTopic != null) {
            client.publishMsg(
                client.disconnectTopic!, client.disconnectMessage);
          }
        })
        .then((_) => client.mqttClient.disconnect())
        .then((_) =>
            Navigator.pushReplacementNamed(context, AuthScreen.routeName));
  }
}
