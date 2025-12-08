import 'package:flutter/material.dart';

class MyAppGradient{
  static const myAppGradient = LinearGradient(
    colors: [
    Color.fromARGB(255, 245, 245, 245),
    Color.fromARGB(255, 39, 245, 245),
    Color.fromARGB(255, 39, 230, 245),
    Color.fromARGB(255, 39, 210, 245)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}