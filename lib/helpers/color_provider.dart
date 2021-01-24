
import 'package:flutter/material.dart';

class ColorProvider {
  static final ColorProvider shared = ColorProvider._internal();

  factory ColorProvider() {
    return shared;
  }
  ColorProvider._internal();

  Color standardAppBackgroundColor =  Color.fromRGBO(238, 230, 230, 1.0);

  Color sensorCellBackgroundColor =  Color.fromRGBO(240, 231, 231, 1.0);

  Color standardAppButtonColor =  Color.fromRGBO(0, 145, 110, 1.0);

  Color standardAppButtonBorderColor =  Color.fromRGBO(76, 76, 76, 1.0);

  Color standardAppButtonTextColor =  Color.fromRGBO(255, 255, 255, 1.0);

  Color standardAppLeftMenuBackgroundColor =  Color.fromRGBO(28, 108, 78, 1.0);

  Color loadingIndicatorColor =  Color.fromRGBO(215, 215, 215, 1.0);

  Color loadingIndicatorCircleColor =  Color.fromRGBO(28, 108, 78, 1.0);

  Color loadingIndicatorAnimationColor =  Color.fromRGBO(0, 145, 110, 1.0);


}