import 'dart:async';
import 'package:Whiff/modules/historical/HistoricalPage.dart';
import 'package:Whiff/modules/state/StateViewModel.dart';
import 'package:Whiff/modules/welcome/WelcomePageViewModel.dart';
import 'package:Whiff/modules/state/StatePage.dart';
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

class SecondWelcomePage extends StatefulWidget {
  @override
  SecondWelcomePageState createState() => SecondWelcomePageState();
}

class SecondWelcomePageState extends State<SecondWelcomePage> {

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

  @override
  void initState() {
    super.initState();
  }


  @override
  void deactivate() {
    super.deactivate();
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
                    Image.asset('assets/good_small.png', width: 250, height: 180),]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context).translate("second_welcome_page_title"),  style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
                  ]),
              SizedBox(height: 8,),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(width:300,
                        alignment: Alignment.center,
                        child:  Text(AppLocalizations.of(context).translate("second_welcome_subtitle"), textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontFamily: 'Poppins')))]),
              SizedBox(height: 8,),

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
                          onPressed: (){
                            Navigator.of(context).pushReplacement( MaterialPageRoute(builder: (context) => StatePage()));
                          } ,
                          color: ColorProvider.shared.standardAppButtonColor,
                          textColor: ColorProvider.shared.standardAppButtonTextColor,
                          child: Text(
                            AppLocalizations.of(context).translate("second_welcome_page_add_sensor_button_title"),
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
                          onPressed: (){
                              _launchURL("http://whiff.zone");
                          } ,
                          color: ColorProvider.shared.standardAppButtonColor,
                          textColor: ColorProvider.shared.standardAppButtonTextColor,
                          child: Text(
                            AppLocalizations.of(context).translate("second_welcome_page_request_demo_button_title"),
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

