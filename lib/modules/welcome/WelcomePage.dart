import 'dart:async';
import 'package:Whiff/modules/historical/HistoricalPage.dart';
import 'package:Whiff/modules/secondWelcome/secondWelcome.dart';
import 'package:Whiff/modules/sensorManager/SensorManagerPage.dart';

import 'package:Whiff/modules/state/StateViewModel.dart';
import 'package:Whiff/modules/welcome/WelcomePageViewModel.dart';
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

  WelcomePageViewModelContract _viewModel = WelcomePageViewModel();

  StreamSubscription _demoStateSubscription;
  StreamSubscription _demoErrorMessageSubscription;

  bool _didRequestDemo = false;

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

    _demoStateSubscription = _viewModel.demoState().listen((state) {
      print("haha");
      print(state);
      if(state == true ) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SecondWelcomePage(true)));
      }
    });

    _demoErrorMessageSubscription = _viewModel.demoErrorMessage().listen((message) {
      if(message != null) {
        _didRequestDemo = false;
        setState(() {
          showAlert(context, message);
        });
      }
    });
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
      _didRequestDemo == true ? LoadingIndicator(): Column(
      mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Image.asset('assets/meh-solid.png', width: 250, height: 180),]),
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context).translate("welcome_page_title"),  style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
              ]),
          SizedBox(height: 20,),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(width:300,
                    alignment: Alignment.center,
                    child:  Text(AppLocalizations.of(context).translate("welcome_page_subtitle"), textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontFamily: 'Poppins')))]),
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
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => SensorManagerPage()));
                      } ,
                      color: ColorProvider.shared.standardAppButtonColor,
                      textColor: ColorProvider.shared.standardAppButtonTextColor,
                      child: Text(
                        AppLocalizations.of(context).translate("welcome_page_add_sensor_button_title"),
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
                        _didRequestDemo = true;
                        _viewModel.requestDemo();
                        setState(() {});
                      } ,
                      color: ColorProvider.shared.standardAppButtonColor,
                      textColor: ColorProvider.shared.standardAppButtonTextColor,
                      child: Text(
                          AppLocalizations.of(context).translate("welcome_page_request_demo_button_title"),
                      )
                  ),


                )
              ]
          ),
          SizedBox(height: 20,),
        ])

    );


  }


  void showAlert(BuildContext context, String text) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(text),
        actions: [
          okButton,
        ],
      ),
    );
  }







}

