import 'package:Whiff/model/WhiffError.dart';
import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:Whiff/helpers/app_localizations.dart';

class FailurePage extends StatelessWidget {

  WhiffError _error;
  VoidCallback onPressedContactButton;
  VoidCallback onPressedReloadButton;
  FailurePage(this._error, this.onPressedReloadButton, this.onPressedContactButton);

  @override
  Widget build(BuildContext context) {

    final double _kImageWidth = 300;
    final double _kImageHeight = 200;

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _error.errorCode != 1002 ? Image.asset('assets/sad-tear-solid.png', width: _kImageWidth,
                  height: _kImageHeight) :  Image.asset('assets/meh-solid.png', width: _kImageWidth,
                  height: _kImageHeight) ,
            ],
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _error.errorCode != 1002 ? Text( AppLocalizations.of(context).translate("failure_page_title"), style: TextStyle(fontSize: 17, fontFamily: 'Poppins')) : Text( AppLocalizations.of(context).translate("failure_page_empty_sensors_list_title"), style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
                ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 Container(width:300,
                 alignment: Alignment.center,
                 child: _error.isLocalError() ? Text( AppLocalizations.of(context).translate(_error.errorMessage), style: TextStyle(fontSize: 14, fontFamily: 'Poppins'), textAlign: TextAlign.center,): Text(AppLocalizations.of(context).translate("error_server_response_message") + _error.errorMessage, style: TextStyle(fontSize: 14, fontFamily: 'Poppins'), textAlign: TextAlign.center,),
                 )
              ]),
          SizedBox(height: 20,),
           Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 2*15,
                  height: 40,
                  child:
                  RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: ColorProvider.shared.standardAppButtonBorderColor),
                      ),
                      onPressed: onPressedReloadButton  ,
                      color: ColorProvider.shared.standardAppButtonColor,
                      textColor: ColorProvider.shared.standardAppButtonTextColor,
                      child: Text(
                        AppLocalizations.of(context).translate('failure_page_try_again_button_title'),
                      )
                  ),
                )
              ]
          ),
          SizedBox(height: 20,),
          _error.errorCode != 1001 ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 2*15,
                  height: 40,
                  child:
                  RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: ColorProvider.shared.standardAppButtonBorderColor),
                      ),
                      onPressed: onPressedContactButton,
                      color: ColorProvider.shared.standardAppButtonColor,
                      textColor: ColorProvider.shared.standardAppButtonTextColor,
                      child: Text(
                        AppLocalizations.of(context).translate('failure_page_contact_support_button_title'),
                      )
                  ),
                )
              ]
          ) : SizedBox(height: 0,),
        ]);

  }
}

//  _error.errorCode != 1001 ?
  //  : ,