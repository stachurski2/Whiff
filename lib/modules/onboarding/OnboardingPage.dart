import 'dart:async';

import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/modules/onboarding/OnboardingViewModel.dart';

import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:Whiff/model/Sensor.dart';

class OnboardingPage extends StatefulWidget {
  @override
  OnboardingPageState createState() => OnboardingPageState();
}

class OnboardingPageState extends State<OnboardingPage>  {

  OnboardingViewModelContract _viewModel = OnboardingViewModel();

  StreamSubscription onboardingState;

  StreamSubscription sensorListSubscription;

  var _sensors = List<Sensor>();

  final AutheticatingServicing authenticationService = AutheticationService.shared;

  @override
  void deactivate() {
    this.onboardingState.cancel();
    this.sensorListSubscription.cancel();
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    onboardingState = _viewModel.currentAuthState().listen((state) {
      if(state.signedIn == false ) {
        Navigator.pop(context);
        Navigator.of(context).pop(true);
      }
    });


    sensorListSubscription = _viewModel.sensorsList().listen((sensorList) {
      this.setState(() {
        this._sensors = sensorList;
      });
    });

    _viewModel.fetchSensors();
  }

  Widget build(BuildContext context)  {

    return WillPopScope(child: Scaffold(
      backgroundColor: ColorProvider.shared.standardAppBackgroundColor,
      appBar: AppBar(backgroundColor: ColorProvider.shared.standardAppBackgroundColor, iconTheme: IconThemeData(color: ColorProvider.shared.standardAppLeftMenuBackgroundColor)),
      body: Container(
        child: ListView.separated(
    itemCount: _sensors.length,
    separatorBuilder:  ( BuildContext context, int index) => SizedBox(height: 20),
    itemBuilder: (BuildContext context, int index) {
                return
                Column(
                  children: [
                    SizedBox(height: 20),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [ Text( "Sensor name: "  + _sensors[index].name)]),
                      Row(mainAxisAlignment: MainAxisAlignment.center,
                                   children: [ Text( "Location: "  + _sensors[index].locationName)]),
                    SizedBox(height: 20)

                  ],);

                  Row(children: [ Text(_sensors[index].name)]);
    },),),
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
                            _viewModel.signOut();
                          }, child: Text("Sign out",textAlign: TextAlign.left, style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Poppins')))
                      ],
                    )
                  ),
          ],
        ),
    ),
        ),

      ),
      ),
    ),
      onWillPop: () async => false,
    );
  }
}

