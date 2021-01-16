
import 'package:flutter/material.dart';

class ColorProvider {
  static final ColorProvider shared = ColorProvider._internal();

  factory ColorProvider() {
    return shared;
  }
  ColorProvider._internal();

  Color standardAppBackgroundColor =  Color.fromRGBO(255, 255, 255, 1.0);

  Color standardAppButtonColor =  Color.fromRGBO(0, 145, 110, 1.0);

  Color standardAppButtonBorderColor =  Color.fromRGBO(76, 76, 76, 1.0);

  Color standardAppButtonTextColor =  Color.fromRGBO(255, 255, 255, 1.0);

}