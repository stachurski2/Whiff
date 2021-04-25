
import 'package:flutter/material.dart';

class ColorProvider {
  static final ColorProvider shared = ColorProvider._internal();

  factory ColorProvider() {
    return shared;
  }
  ColorProvider._internal();

  Color standardTextColor =  Color.fromRGBO(0, 0, 0, 1.0);

  Color standardAppBackgroundColor =  Color.fromRGBO(219, 220, 219, 1.0);

  Color sensorCellBackgroundColor =  Color.fromRGBO(242, 242, 242, 1.0);

  Color standardAppButtonColor =  Color.fromRGBO(0, 145, 110, 1.0);

  Color standardAppButtonBorderColor =  Color.fromRGBO(76, 76, 76, 1.0);

  Color standardAppButtonTextColor =  Color.fromRGBO(255, 255, 255, 1.0);

  Color standardAppLeftMenuBackgroundColor =  Color.fromRGBO(28, 108, 78, 1.0);

  Color loadingIndicatorColor =  Color.fromRGBO(215, 215, 215, 1.0);

  Color loadingIndicatorCircleColor =  Color.fromRGBO(28, 108, 78, 1.0);

  Color loadingIndicatorAnimationColor =  Color.fromRGBO(0, 145, 110, 1.0);

  Color measurumentGoodLevel = Color.fromRGBO(28, 108, 78, 1.0);

  Color measurumentModerateLevel =  Color.fromRGBO(250, 186, 16, 1.0);

  Color measurumentBadLevel =  Color.fromRGBO(245, 0, 22, 1.0);

  Color measurumentVeryBadLevel =  Color.fromRGBO(177, 0, 16, 1.0);


}