import 'dart:async';
import 'package:Whiff/modules/historical/HistoricalPage.dart';
import 'package:Whiff/modules/state/StateViewModel.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Whiff/Services/Authetication/Authetication.dart';

import 'package:Whiff/modules/onboarding/OnboardingPage.dart';

import 'package:Whiff/modules/accountSettings/AccountSettingsPage.dart';
import 'package:Whiff/customView/LoadingIndicator.dart';
import 'package:Whiff/helpers/app_localizations.dart';
import 'package:Whiff/model/AirState.dart';
import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:Whiff/customView/AirStatePage.dart';

class WelcomePage extends StatefulWidget {
  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  final double _kImageWidth = 250;
  final double _kImageHeight = 250;
  bool _didLoad = false;

  final AutheticatingServicing authenticationService = AutheticationService
      .shared;

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _mailToSupport() async {
    final mailtoLink = Mailto(
      to: ['support@whiff.zone'],
      cc: [''],
      subject: 'An encountered issue within the Whiff App',
      body: 'Provide here info about the issue.',
    );

    await _launchURL(mailtoLink.toString());
  }

  void _reload() {

    setState(() {});

  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ColorProvider.shared.standardAppBackgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(""),
          automaticallyImplyLeading: false,
          iconTheme: IconThemeData(
              color: ColorProvider.shared.standardAppLeftMenuBackgroundColor)),
      body:
      Column(
      mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Image.asset('assets/meh-solid.png', width: 300, height: 200),]),



              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text( AppLocalizations.of(context).translate("Nice to see you!"))
              ]),
          SizedBox(height: 20,),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(width:300,
                    alignment: Alignment.center,
                    child:  Text(AppLocalizations.of(context).translate("We are glad, that you use the Whiff App. However, you need the Whiff sensor to provide data to your account . If you don’t own the Whiff Sensor you could add demo sensors to your account"), textAlign: TextAlign.center,))]),
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
                      onPressed: (){} ,
                      color: ColorProvider.shared.standardAppButtonColor,
                      textColor: ColorProvider.shared.standardAppButtonTextColor,
                      child: Text(
                        AppLocalizations.of(context).translate("Add sensors"),
                      )
                  ),


                )
              ]
          ),
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
                      onPressed: (){} ,
                      color: ColorProvider.shared.standardAppButtonColor,
                      textColor: ColorProvider.shared.standardAppButtonTextColor,
                      child: Text(
                        AppLocalizations.of(context).translate("Use demo sensors"),
                      )
                  ),


                )
              ]
          ),
          SizedBox(height: 20,),
        ])

    );


  }








}

