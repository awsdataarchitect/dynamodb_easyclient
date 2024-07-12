import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(String text, BuildContext context,
    {bool center = false, int sec = 5}) {
  FToast fToast = FToast();
  fToast.init(context);

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0), color: Colors.black87),
    child: Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text(text,
            style: const TextStyle(
              color: Colors.white,
            ))
      ],
    ),
  );

  fToast.showToast(
      child: toast,
      toastDuration: Duration(seconds: sec),
      gravity:
          center || Platform.isIOS ? ToastGravity.CENTER : ToastGravity.BOTTOM);
}
