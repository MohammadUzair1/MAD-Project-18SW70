import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

Flushbar showFailureDialog(BuildContext context, String errorText) {
  return Flushbar(
    titleText: Text(
      'ERROR',
      style: TextStyle(color: Colors.white),
    ),
    messageText: Text(
      errorText,
      style: TextStyle(color: Colors.white),
    ),
    duration: Duration(seconds: 2),
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.FLOATING,
    reverseAnimationCurve: Curves.decelerate,
    forwardAnimationCurve: Curves.elasticOut,
    backgroundColor: Colors.red,
    margin: EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    boxShadows: [
      BoxShadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 3.0)
    ],
    backgroundGradient: LinearGradient(colors: [Colors.red, Colors.red[500]!]),
    icon: Icon(
      Icons.error,
      color: Colors.white,
    ),
  );
}

Flushbar showSuccessDialog(BuildContext context, String successText) {
  return Flushbar(
    titleText: Text(
      'SUCCESS',
      style: TextStyle(color: Colors.white),
    ),
    messageText: Text(
      successText,
      style: TextStyle(color: Colors.white),
    ),
    duration: Duration(seconds: 2),
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.FLOATING,
    reverseAnimationCurve: Curves.decelerate,
    forwardAnimationCurve: Curves.elasticOut,
    backgroundColor: Colors.green,
    margin: EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    boxShadows: [
      BoxShadow(color: Colors.grey, offset: Offset(2.0, 2.0), blurRadius: 3.0)
    ],
    backgroundGradient:
        LinearGradient(colors: [Colors.green, Colors.green[500]!]),
    icon: Icon(
      Icons.error,
      color: Colors.white,
    ),
  );
}
