import 'dart:async';

import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/Services/Networking/Networking.dart';

import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:Whiff/helpers/app_localizations.dart';
import 'package:rxdart/rxdart.dart';


class OnboardingPage extends StatefulWidget {
  @override
  OnboardingPageState createState() => OnboardingPageState();
}


class OnboardingPageState extends State<OnboardingPage>  {


  StreamSubscription onboardingState;

 final AutheticatingServicing authenticationService = AutheticationService.shared;

  @override
  void deactivate() {
    this.onboardingState.cancel();
    super.deactivate();
  }


  Widget build(BuildContext context)  {

    this.onboardingState = authenticationService.currentAuthState().listen((state) {
      if(state.signedIn == false ) {
        Navigator.pop(context);
        Navigator.of(context).pop(true);
      }
    });

    return WillPopScope(child: Scaffold(
      backgroundColor: ColorProvider.shared.standardAppBackgroundColor,
      body: AppBar(backgroundColor: ColorProvider.shared.standardAppBackgroundColor, iconTheme: IconThemeData(color: ColorProvider.shared.standardAppLeftMenuBackgroundColor)),

      drawer: Theme(
        data:  Theme.of(context).copyWith(
          canvasColor: ColorProvider.shared.standardAppLeftMenuBackgroundColor, //This will change the drawer background to blue.
          //other styles
        ),
        child:
      Drawer(
        child: Container(
            padding: EdgeInsets.only(top: 20),
            color:  ColorProvider.shared.standardAppLeftMenuBackgroundColor,
            child:

    Container(
    color:  Colors.white,
    child:

            ListView(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 0),
            children: [
              Container(height: 50, color: ColorProvider.shared.standardAppButtonColor,
                            padding: EdgeInsets.only(left: 20, bottom: 10),
                            alignment: Alignment.bottomLeft,
                            child: Text(authenticationService.signedInEmail(),textAlign: TextAlign.left, style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Poppins')),
                    ),
                  Container(height: 80, color: Colors.white),
                  Container(height: 50, color: Colors.white,
                    padding: EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child:
                        Row( children: [
                          TextButton(onPressed: () {

                          }, child: Text("Current data",textAlign: TextAlign.left, style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Poppins')))
                        ],)
                  ),
                  Container(height: 50, color: Colors.white,
                      padding: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child:
                      Row( children: [
                        TextButton(onPressed: () {

                        }, child: Text("Historical data",textAlign: TextAlign.left, style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Poppins')))
                      ],)
                  ),
                  Container(height: 50, color: Colors.white,
                      padding: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child:
                      Row( children: [
                        TextButton(onPressed: () {

                        }, child: Text("Account Settings",textAlign: TextAlign.left, style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Poppins')))


                      ],)
                  ),
                  Container(height: 50, color: Colors.white,
                      padding: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child:
                      Row(children: [
                          TextButton(onPressed: () {
                            this.authenticationService.signOut();
                          }, child: Text("Sign out",textAlign: TextAlign.left, style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Poppins')))
                      ],
                    )
                  ),
          ],
        ),
    ),
        ),

     //   child:


        // ListView(
        //   children: [
        //
        //     ),
        //   ],
        // ),
      ),
      ),
    ),
      onWillPop: () async => false,
    );
  }
}
