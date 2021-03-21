import 'dart:async';
import 'package:Whiff/modules/historical/HistoricalPage.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/customView/FailurePage.dart';
import 'package:Whiff/model/WhiffError.dart';
import 'package:Whiff/modules/onboarding/OnboardingViewModel.dart';
import 'package:Whiff/modules/measurement/MasurementPage.dart';
import 'package:Whiff/modules/accountSettings/AccountSettingsPage.dart';
import 'package:Whiff/customView/LoadingIndicator.dart';
import 'package:Whiff/helpers/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:flutter/rendering.dart';

class OnboardingPage extends StatefulWidget {
  @override
  OnboardingPageState createState() => OnboardingPageState();
}

class OnboardingPageState extends State<OnboardingPage> {
  final double _kImageWidth = 120;
  final double _kImageHeight = 60;
  bool _didLoad = false;

  OnboardingViewModelContract _viewModel = OnboardingViewModel();

  StreamSubscription onboardingState;

  StreamSubscription sensorListSubscription;

  StreamSubscription sensorListErrorSubscription;


  var _sensors = List<Sensor>();
  WhiffError _error;

  final AutheticatingServicing authenticationService = AutheticationService
      .shared;

  void showMeasurementPage(Sensor sensor) {
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => MeasurementPage(sensor)),
    );
  }

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _mailToSupport() async {
    final mailtoLink = Mailto(
      to: ['to@example.com'],
      cc: ['cc1@example.com', 'cc2@example.com'],
      subject: 'mailto example subject',
      body: 'mailto example body',
    );

    await _launchURL(mailtoLink.toString());
  }

  void _reload() {
    _error = null;
    _didLoad = false;
    setState(() {});
    _viewModel.fetchSensors();
  }

  @override
  void deactivate() {
    this.onboardingState.cancel();
    this.sensorListSubscription.cancel();
    this.sensorListErrorSubscription.cancel();
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    onboardingState = _viewModel.currentAuthState().listen((state) {
      if (state.signedIn == false) {
        Navigator.pop(context);
        Navigator.of(context).pop(true);
      }
    });
    sensorListSubscription = _viewModel.sensorsList().listen((sensorList) {
      this.setState(() {
        this._sensors = sensorList;
        this._didLoad = true;
      });
    });

    sensorListErrorSubscription =
        _viewModel.sensorsListFetchError().listen((error) {
          this._error = error;
          this.setState(() {});
        });

    _viewModel.fetchSensors();
  }

  Widget build(BuildContext context) {
    Widget sensorListView() {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.zero,
        itemCount: _sensors.length,
        itemBuilder: (BuildContext context, int index) {
          return
            GestureDetector(child:
            Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(
                        color: ColorProvider.shared
                            .standardAppButtonBorderColor),
                        top: BorderSide(
                            color: index == 0 ? ColorProvider.shared
                                .standardAppButtonBorderColor : Colors
                                .transparent)),
                    color: ColorProvider.shared.sensorCellBackgroundColor),
                child:
                Column(
                  children: [
                    SizedBox(height: 20),

                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [ Text("Sensor " + (index + 1).toString(),
                            style: TextStyle(fontSize: 22,
                                fontFamily: 'Poppins')),
                          SizedBox(width: 20),
                          Column(
                            children: [ Text(
                                "Sensor: " + _sensors[index].name,
                                textAlign: TextAlign.left), Text(
                                "Location: " + _sensors[index].locationName,
                                textAlign: TextAlign.left)
                            ],)

                        ]),


                    SizedBox(height: 20)

                  ],)
            ),
              onTap: () =>
              {
                this.showMeasurementPage(_sensors[index])
              },
            );
        },);
    }

    Widget failureView(WhiffError error, VoidCallback onPressedReloadButton,
        VoidCallback onPressedContactButton) {
      return Column(
        children: [
          SizedBox(height: 60),
          Image.asset('assets/whiffLogo.png', width: _kImageWidth,
              height: _kImageHeight),

          FailurePage(error, onPressedReloadButton, onPressedContactButton),
        ],
      );
    }

    return WillPopScope(child: Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: ColorProvider.shared.standardAppBackgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
              color: ColorProvider.shared.standardAppLeftMenuBackgroundColor)),
      body:
      SingleChildScrollView(
        child: (_error != null) ? failureView(_error, () {
          this._reload();
        }, () async {
          await this._mailToSupport();
        }) :
        Column(
          children: [
            SizedBox(height: 60),
            Image.asset('assets/cloud-sun-solid.png', width: _kImageWidth,
                height: _kImageHeight),
            Image.asset('assets/whiffLogo.png', width: _kImageWidth,
                height: _kImageHeight),
            (_didLoad && _sensors.length > 0) ? Text("Select Sensor",
                style: TextStyle(fontSize: 22, fontFamily: 'Poppins')) :  SizedBox(height: 1) ,
            _didLoad ? SizedBox(height: 20) : SizedBox(height: 100),
            _didLoad ? _sensors.length > 0 ? sensorListView(): emptyList() : LoadingIndicator(),
          ],
        )),
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: ColorProvider.shared
              .standardAppLeftMenuBackgroundColor, //This will change the drawer background to blue.
          //other styles
        ),
        child:
        Drawer(
          child: Container(
            padding: EdgeInsets.only(top: 20),
            color: ColorProvider.shared.standardAppLeftMenuBackgroundColor,
            child:

            Container(
              color: ColorProvider.shared.standardAppBackgroundColor,
              child:

              ListView(
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 0),
                children: [
                  Container(
                    height: 50,
                    color: ColorProvider.shared.standardAppButtonColor,
                    padding: EdgeInsets.only(left: 20, bottom: 10),
                    alignment: Alignment.bottomLeft,
                    child: Text(authenticationService.signedInEmail(),
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Poppins')),
                  ),
                  Container(height: 80,
                      color: ColorProvider.shared.standardAppBackgroundColor),
                  Container(height: 50,
                      color: ColorProvider.shared.standardAppBackgroundColor,
                      padding: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child:
                      Row(children: [
                        TextButton(onPressed: () {
                          Navigator.of(context).pop();
                        },
                            child: Text(
                                AppLocalizations.of(context).translate('menu_current_data_button'),
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Poppins')))
                      ],)
                  ),
                  Container(height: 50,
                      color: ColorProvider.shared.standardAppBackgroundColor,
                      padding: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child:
                      Row(children: [
                        TextButton(onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushReplacement( MaterialPageRoute(builder: (context) => HistoricalPage()));
                        },
                            child: Text(
                                AppLocalizations.of(context).translate('menu_historical_data_button'),
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Poppins')))
                      ],)
                  ),
                  Container(height: 50,
                      color: ColorProvider.shared.standardAppBackgroundColor,
                      padding: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child:
                      Row(children: [
                        TextButton(onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushReplacement( MaterialPageRoute(builder: (context) => AccountSettingsPage()));
                        },
                            child: Text(
                                AppLocalizations.of(context).translate('menu_account_settings_button'),
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Poppins')))


                      ],)
                  ),
                  Container(height: 50,
                      color: ColorProvider.shared.standardAppBackgroundColor,
                      padding: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child:
                      Row(children: [
                        TextButton(onPressed: () {
                          _viewModel.signOut();
                        },
                            child: Text(AppLocalizations.of(context).translate('menu_sing_out_button'),
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Poppins')))
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


  Widget emptyList() {
    return Column(
      children: [
        // SizedBox(height: 60),
        // Image.asset('assets/whiffLogo.png', width: _kImageWidth,
        //     height: _kImageHeight),

        FailurePage(WhiffError(1002,     AppLocalizations.of(context).translate('failure_page_empty_sensors_list_message')), () {
          this._reload();
        }, () async {
          await this._mailToSupport();
        })
      ],
    );
  }
}

