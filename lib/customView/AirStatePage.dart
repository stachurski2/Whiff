import 'package:Whiff/customView/LoadingIndicator.dart';
import 'package:Whiff/model/AirState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:Whiff/helpers/app_localizations.dart';

class AirStatePage extends StatelessWidget {

  AirState _airState;
  VoidCallback onPressedShowDetailsButtonButton;
  AirStatePage(this._airState, this.onPressedShowDetailsButtonButton);

  @override
  Widget build(BuildContext context) {

    final double _kImageWidth = 300;
    final double _kImageHeight = 200;
    print(_airState);
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _airState == null ?
              LoadingIndicator()
          :Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _airState == AirState.good ? Image.asset('assets/smile-solid.png', width: _kImageWidth,
                  height: _kImageHeight) : _airState == AirState.moderate ? Image.asset('assets/meh-solid.png', width: _kImageWidth,
                  height: _kImageHeight) :  (_airState == AirState.bad  || _airState == AirState.veryBad ) ? Image.asset('assets/frown-solid.png', width: _kImageWidth,
                  height: _kImageHeight) : Image.asset('assets/sad-tear-solid.png', width: _kImageWidth,
                  height: _kImageHeight) ,
            ],
          ),
          _airState == null ?
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
            Text(AppLocalizations.of(context).translate("air_page_loading_label_text"), style: TextStyle(fontSize: 17, fontFamily: 'Poppins'), textAlign: TextAlign.center)
    ])
          :Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               Text((_airState == AirState.good ? AppLocalizations.of(context).translate("onboarding_air_state_good") : _airState == AirState.moderate ? AppLocalizations.of(context).translate("onboarding_air_state_moderate") : _airState == AirState.bad ? AppLocalizations.of(context).translate("onboarding_air_state_bad"): _airState == AirState.veryBad ? AppLocalizations.of(context).translate("onboarding_air_state_very_bad"): AppLocalizations.of(context).translate("onboarding_air_state_unknown")), style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
              ]),
          _airState == null ?
              SizedBox(height: 1,):
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(width:300,
                  alignment: Alignment.center,
                  child:  Text((_airState == AirState.good ? AppLocalizations.of(context).translate("onboarding_air_state_good_description") : _airState == AirState.moderate ? AppLocalizations.of(context).translate("onboarding_air_state_moderate_description") : _airState == AirState.bad ? AppLocalizations.of(context).translate("onboarding_air_state_bad_description"): _airState == AirState.veryBad ? AppLocalizations.of(context).translate("onboarding_air_state_very_bad_description"): AppLocalizations.of(context).translate("onboarding_air_state_unknown_description")), style: TextStyle(fontSize: 14, fontFamily: 'Poppins'), textAlign: TextAlign.center,))              ]),
          SizedBox(height: 20,),
          _airState == null ?
          SizedBox(height: 1,):
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 2*10,
                  height: 40,
                  child:
                  RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: ColorProvider.shared.standardAppButtonBorderColor),
                      ),
                      onPressed: onPressedShowDetailsButtonButton  ,
                      color: ColorProvider.shared.standardAppButtonColor,
                      textColor: ColorProvider.shared.standardAppButtonTextColor,
                      child: Text(
                       AppLocalizations.of(context).translate("air_page_show_details_label_text"),
                      )
                  ),
                )
              ]
          ),
          SizedBox(height: 20,),
        ]);

  }
}
