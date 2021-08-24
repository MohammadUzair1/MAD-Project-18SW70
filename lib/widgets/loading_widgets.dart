import 'package:flutter/material.dart';

Widget circularProgress({Color color = Colors.white}) {
  return CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation(color),
  );
}
