import 'package:flutter/material.dart';

const String appServiceAccountUrl =
    '/opt/notifications-tracker-aeaa0a8324e9.json';
//Toast msg
const String testNotificationValidationMsg =
    'Receipt validation is not applicable for Test Notification';
const String emailVerificationFailedMsg =
    'Please check your inbox and verify your email';
const String unknownErrorMsg = 'Some unknown error happend try again';

//colors
Color c1 = const Color(0xff22a45c);
Color c2 = const Color(0xff4186f2);
Color c3 = const Color(0xff3a5999);

//test Field decoration
var textFieldColor = Colors.blue;

var loginTextInputDecoration = InputDecoration(
  hintStyle: const TextStyle(color: Colors.grey),
  enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: Colors.grey[200])),
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: Colors.grey[200])),
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: c1)),
);
