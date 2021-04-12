import 'package:Whiff/model/AirState.dart';
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

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _airState == AirState.good ? Image.asset('assets/smile-solid.png', width: _kImageWidth,
                  height: _kImageHeight) : _airState == AirState.moderate ? Image.asset('assets/meh-solid.png', width: _kImageWidth,
                  height: _kImageHeight) :  (_airState == AirState.bad  || _airState == AirState.veryBad ) ? Image.asset('assets/frown-solid.png', width: _kImageWidth,
                  height: _kImageHeight) : Image.asset('assets/sad-tear-solid.png', width: _kImageWidth,
                  height: _kImageHeight) ,
            ],
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               Text((_airState == AirState.good ? "air is good" : _airState == AirState.moderate ? "air is moderate" : _airState == AirState.bad ? "air is bad": _airState == AirState.veryBad ? "air is very bad": "didn't get data :/"), style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(width:300,
                  alignment: Alignment.center,
                  child:  Text((_airState == AirState.good ? "air is good" : _airState == AirState.moderate ? "air is moderate" : _airState == AirState.bad ? "air is bad": _airState == AirState.veryBad ? "air is very bad": "didn't get data :/"), style: TextStyle(fontSize: 14, fontFamily: 'Poppins'), textAlign: TextAlign.center,))              ]),
          SizedBox(height: 20,),
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
                       "Show Details",
                      )
                  ),
                )
              ]
          ),
          SizedBox(height: 20,),
        ]);

  }
}

//  _error.errorCode != 1001 ?
//  : ,