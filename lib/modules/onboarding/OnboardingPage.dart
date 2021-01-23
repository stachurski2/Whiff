import 'dart:async';

import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/modules/onboarding/OnboardingViewModel.dart';
import 'package:Whiff/modules/measurement/MasurementPage.dart';

import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:flutter/rendering.dart';

class OnboardingPage extends StatefulWidget {
  @override
  OnboardingPageState createState() => OnboardingPageState();
}

class OnboardingPageState extends State<OnboardingPage>  {
  final double _kImageWidth = 120;
  final double _kImageHeight = 60;

  OnboardingViewModelContract _viewModel = OnboardingViewModel();

  StreamSubscription onboardingState;

  StreamSubscription sensorListSubscription;

  var _sensors = List<Sensor>();

  final AutheticatingServicing authenticationService = AutheticationService.shared;

  void showMeasurementPage(Sensor sensor) {
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => MeasurementPage(sensor)),
    );
  }

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
      extendBodyBehindAppBar:true,
      backgroundColor: ColorProvider.shared.standardAppBackgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation:0, iconTheme: IconThemeData(color: ColorProvider.shared.standardAppLeftMenuBackgroundColor)),
      body:
    SingleChildScrollView(
    child:
      Column(
        children:[
          SizedBox(height: 60),
          Image.asset('assets/cloud-sun-solid.png', width: _kImageWidth,
              height: _kImageHeight),
          Image.asset('assets/whiffLogo.png', width: _kImageWidth,
              height: _kImageHeight),
          Text("Select Sensor",  style: TextStyle(fontSize: 22, fontFamily: 'Poppins')),
          SizedBox(height: 20),
          //if()
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.zero,
            itemCount: _sensors.length,
           itemBuilder: (BuildContext context, int index) {
                return
                 GestureDetector(child:
                Container(
                  decoration:  BoxDecoration(
                      border: Border(bottom: BorderSide(color: ColorProvider.shared.standardAppButtonBorderColor), top: BorderSide(color: index == 0 ? ColorProvider.shared.standardAppButtonBorderColor : Colors.transparent)),
                                      color:  ColorProvider.shared.sensorCellBackgroundColor),
                  child:
                Column(
                  children: [
                    SizedBox(height: 20),

                        Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [ Text("Sensor "+ (index+1).toString(), style: TextStyle(fontSize: 22, fontFamily: 'Poppins')),
                              SizedBox(width: 20),
                              Column(
                                children: [ Text( "Sensor: "  + _sensors[index].name, textAlign: TextAlign.left), Text( "Location: "  + _sensors[index].locationName, textAlign: TextAlign.left)],)

                             ]),


                    SizedBox(height: 20)

                  ],)
                ),
                   onTap: () => {
                        this.showMeasurementPage(_sensors[index])
                   },
                );

    },),
           ],
    ),),
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
    color: ColorProvider.shared.standardAppBackgroundColor,
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
                  Container(height: 80, color: ColorProvider.shared.standardAppBackgroundColor),
                  Container(height: 50, color: ColorProvider.shared.standardAppBackgroundColor,
                    padding: EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child:
                        Row( children: [
                          TextButton(onPressed: () {

                          }, child: Text("Current data",textAlign: TextAlign.left, style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Poppins')))
                        ],)
                  ),
                  Container(height: 50, color: ColorProvider.shared.standardAppBackgroundColor,
                      padding: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child:
                      Row( children: [
                        TextButton(onPressed: () {

                        }, child: Text("Historical data",textAlign: TextAlign.left, style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Poppins')))
                      ],)
                  ),
                  Container(height: 50, color: ColorProvider.shared.standardAppBackgroundColor,
                      padding: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child:
                      Row( children: [
                        TextButton(onPressed: () {

                        }, child: Text("Account Settings",textAlign: TextAlign.left, style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Poppins')))


                      ],)
                  ),
                  Container(height: 50, color: ColorProvider.shared.standardAppBackgroundColor,
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

