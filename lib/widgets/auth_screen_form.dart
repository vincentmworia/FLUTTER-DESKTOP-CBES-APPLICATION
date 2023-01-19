import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../screens/auth_screen.dart';
import './input_field.dart';
import '../helpers/custom_data.dart';
import './custom_check_box.dart';

class AuthScreenForm extends StatefulWidget {
  const AuthScreenForm({
    Key? key,
    required this.authMode,
    required this.submit,
    required this.isLoading,
    required this.switchAuthMode,
  }) : super(key: key);
  final AuthMode authMode;
  final Function submit;
  final Function switchAuthMode;
  final bool isLoading;

  @override
  State<AuthScreenForm> createState() => _AuthScreenFormState();
}

class _AuthScreenFormState extends State<AuthScreenForm> {
  late AuthMode _authMode;
  final user = User();

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _phoneNumberFocusNode = FocusNode();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _authMode = widget.authMode;
  }

  @override
  void dispose() {
    super.dispose();
    if (kDebugMode) {
      print('FORM DISPOSED');
    }

    _emailFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _confirmPasswordController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    const spacing = SizedBox(height: 20);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // titleText,
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'images/cbes_logo_main.PNG',
                fit: BoxFit.cover,
              ),
            ),

            spacing,
            InputField(
              key: const ValueKey('email'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              hintText: 'Email',
              icon: Icons.account_box,
              obscureText: false,
              focusNode: _emailFocusNode,
              autoCorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(
                  _authMode == AuthMode.register
                      ? _firstNameFocusNode
                      : _passwordFocusNode),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              onSaved: (value) {
                user.email = value!;
              },
            ),
            if ((_authMode == AuthMode.register))
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InputField(
                        key: const ValueKey('firstName'),
                        keyboardType: TextInputType.name,
                        controller: _firstNameController,
                        hintText: 'First Name',
                        icon: Icons.person,
                        obscureText: false,
                        focusNode: _firstNameFocusNode,
                        autoCorrect: false,
                        enableSuggestions: false,
                        textCapitalization: TextCapitalization.sentences,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_authMode == AuthMode.register
                                ? _lastNameFocusNode
                                : _passwordFocusNode),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter First Name';
                          }
                          var isCaps = false;
                          for (String val in alphabet) {
                            if (val.toUpperCase() == value[0]) {
                              isCaps = true;
                              break;
                            }
                          }
                          if (!isCaps) {
                            return 'Name must start with a capital letter';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          user.firstName = value!;
                        },
                      ),
                    ),
                    Expanded(
                      child: InputField(
                        key: const ValueKey('lastName'),
                        keyboardType: TextInputType.name,
                        controller: _lastNameController,
                        hintText: 'Last Name',
                        icon: Icons.person,
                        obscureText: false,
                        focusNode: _lastNameFocusNode,
                        autoCorrect: false,
                        enableSuggestions: false,
                        textCapitalization: TextCapitalization.sentences,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_phoneNumberFocusNode),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 4) {
                            return 'Enter Last Name';
                          }
                          var isCaps = false;
                          for (String val in alphabet) {
                            if (val.toUpperCase() == value[0]) {
                              isCaps = true;
                              break;
                            }
                          }
                          if (!isCaps) {
                            return 'Name must start with a capital letter';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          user.lastName = value!;
                        },
                      ),
                    ),
                  ],
                ),
              ),

            if ((_authMode == AuthMode.register))
              InputField(
                key: const ValueKey('phoneNumber'),
                controller: _phoneNumberController,
                hintText: 'Phone Number',
                keyboardType: TextInputType.number,
                icon: Icons.local_phone,
                obscureText: false,
                focusNode: _phoneNumberFocusNode,
                autoCorrect: false,
                enableSuggestions: false,
                textCapitalization: TextCapitalization.sentences,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocusNode),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter Phone Number';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  if (!value.startsWith("+254")) {
                    return 'Use +254700000000 format';
                  }
                  if (value.length != 13) {
                    return 'Invalid phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  user.phoneNumber = value!;
                },
              ),
            InputField(
              key: const ValueKey('password'),
              keyboardType: TextInputType.visiblePassword,
              controller: _passwordController,
              hintText: 'Password',
              icon: Icons.lock,
              obscureText: true,
              focusNode: _passwordFocusNode,
              autoCorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(
                  _authMode == AuthMode.register
                      ? _confirmPasswordFocusNode
                      : null),
              textInputAction: _authMode == AuthMode.register
                  ? TextInputAction.next
                  : TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid password.';
                }
                if (value.length < 7) {
                  return 'Password must be at least 7 characters long';
                }
                if (_passwordController.text.toLowerCase().trim() ==
                        _firstNameController.text.toLowerCase().trim() ||
                    _passwordController.text.toLowerCase().trim() ==
                        '${_firstNameController.text}${_lastNameController.text}'
                            .toLowerCase()
                            .trim() ||
                    _passwordController.text.toLowerCase().trim() ==
                        _lastNameController.text.toLowerCase().trim() ||
                    _passwordController.text.toLowerCase().trim() ==
                        _emailController.text.toLowerCase().trim()) {
                  return 'Password must be different from email and name';
                }
                return null;
              },
              onSaved: (value) {
                user.password = value!;
                // user.password = Crypt.sha256(value!).toString() ;
              },
            ),
            if ((_authMode == AuthMode.register))
              InputField(
                key: const ValueKey('confirmPassword'),
                controller: _confirmPasswordController,
                keyboardType: TextInputType.visiblePassword,
                hintText: 'Confirm Password',
                icon: Icons.lock,
                obscureText: true,
                focusNode: _confirmPasswordFocusNode,
                autoCorrect: false,
                enableSuggestions: false,
                textCapitalization: TextCapitalization.none,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(null),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid password.';
                  }
                  if (_passwordController.text !=
                      _confirmPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            //  todo remember me logic
            spacing,
            if (_authMode == AuthMode.login && deviceWidth > 750)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "Remember Me",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        // color: Colors.black,
                        fontSize: 16.0,
                        // fontWeight: FontWeight.w300,
                      ),
                    ),
                    const CustomCheckBox()
                  ],
                ),
              ),
            spacing,
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    fixedSize:
                        Size(deviceWidth < 1000 ? deviceWidth * 0.2 : 200, 50),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.all(10),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  if (_formKey.currentState == null ||
                      !(_formKey.currentState!.validate())) {
                    return;
                  }
                  _formKey.currentState!.save();
                  // store the button state in shared preferences API

                  if (RememberMeBnState.bnState == true) {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString(RememberMeBnState.rememberMePrefName,
                        json.encode(user.toLoginMap()));
                  }
                  widget.submit(user);
                },
                child:
                // widget.isLoading
                //     ? const Center(
                //         child: CircularProgressIndicator(color: Colors.white),
                //       )
                //     :
                Text(_authMode == AuthMode.login ? "Login" : "Register")),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28.0),
              child: TextButton(
                child: Text(
                  "Click to ${_authMode == AuthMode.login ? "Register" : "Login"}",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  setState(() {
                    _authMode == AuthMode.login
                        ? _authMode = AuthMode.register
                        : _authMode = AuthMode.login;
                  });

                  widget.switchAuthMode(_authMode);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
