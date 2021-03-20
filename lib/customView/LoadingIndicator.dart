import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';

class LoadingIndicator extends StatelessWidget {


  LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: ColorProvider.shared.loadingIndicatorColor,
                    borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  alignment: Alignment.center,
                 //
                  width: 70.0,
                  height: 70.0,
                  child: Padding(padding: const EdgeInsets.all(5.0),child: Center(child: CircularProgressIndicator(backgroundColor: ColorProvider.shared.loadingIndicatorCircleColor,
                  valueColor: AlwaysStoppedAnimation<Color>(ColorProvider.shared.standardAppButtonColor),))),
                ),
              ]),
        ] );

  }
}