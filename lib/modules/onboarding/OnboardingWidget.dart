import 'package:flutter/material.dart';

class OnboardingWidget extends StatelessWidget {

  final double kStandardSizeBoxHeight = 25;
  final double kCentralBoxHeight = 50;
  final double kImageWidth = 300;
  final double kImageHeight = 300;
  final double kFontSize = 25;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                "Test label",
                style: TextStyle(fontSize: kFontSize),
                textAlign: TextAlign.center
            ),
          ],
        ),
      ),
    );
  }
}
