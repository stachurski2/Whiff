import 'dart:async';
import 'package:Whiff/modules/historical/HistoricalPage.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/customView/FailurePage.dart';
import 'package:Whiff/model/WhiffError.dart';
import 'package:Whiff/model/Measurement.dart';
import 'package:sprintf/sprintf.dart';
import 'package:Whiff/modules/login/LoginPage.dart';

import 'package:Whiff/modules/onboarding/OnboardingViewModel.dart';
import 'package:Whiff/modules/measurement/MasurementPage.dart';
import 'package:Whiff/modules/state/StatePage.dart';

import 'package:Whiff/modules/accountSettings/AccountSettingsPage.dart';
import 'package:Whiff/customView/LoadingIndicator.dart';
import 'package:Whiff/helpers/app_localizations.dart';
import 'package:Whiff/model/AirState.dart';
import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:flutter/rendering.dart';
import 'package:maps_launcher/maps_launcher.dart';
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

  StreamSubscription<List<Measurement>> measurementListSubscription;

  StreamSubscription sensorListErrorSubscription;
  
  Map<String, double> temperatures = Map<String, double>();
  Map<String, AirState> states = Map<String, AirState>();


  List<Sensor> _sensors = [];
  Map<String, Measurement> _measurements = Map<String, Measurement>();

  WhiffError _error;

  final AutheticatingServicing authenticationService = AutheticationService
      .shared;

  void showMeasurementPage(Sensor sensor, Measurement measurement) {
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => MeasurementPage(sensor, measurement)),
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
      to: ['support@whiff.zone'],
      cc: [''],
      subject: 'An encountered issue within the Whiff App',
      body: 'Provide here info about the issue.',
    );

    await _launchURL(mailtoLink.toString());
  }

  void _reload() {
    _error = null;
    _didLoad = false;
    setState(() {});
    _viewModel.fetchSensors();
    _viewModel.fetchState();
  }

  @override
  void deactivate() {
    this.onboardingState.cancel();
    this.sensorListSubscription.cancel();
    this.sensorListErrorSubscription.cancel();
    super.deactivate();
  }

  final PageRouteBuilder _homeRoute = PageRouteBuilder(
    pageBuilder: (BuildContext context, _, __) {
      return LoginPage();
    },
  );

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
      sensorList.forEach((sensor) {
        _viewModel.fetchMeasurement(sensor);
      });
    });

    sensorListErrorSubscription =
        _viewModel.sensorsListFetchError().listen((error) {
          this._error = error;
          this.setState(() {});
        });


    measurementListSubscription = _viewModel.currentMeasurements().listen((list) {
        this.temperatures = Map.fromIterable(list, key: (e) => e.deviceNumber.toString(), value: (e) => e.temperature);
        this.states = Map.fromIterable(list, key: (e) => e.deviceNumber.toString(), value: (e) => e.getState());
        this._measurements = Map.fromIterable(list, key: (e) => e.deviceNumber.toString(), value: (e) => e);;
        this.setState(() {});
    });

    _viewModel.fetchSensors();
    _viewModel.fetchState();
  }

  Widget build(BuildContext context) {

    return WillPopScope(child:
    Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: ColorProvider.shared.standardAppBackgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
              color: ColorProvider.shared.standardAppLeftMenuBackgroundColor)),
      body:
      (_error != null) ? failureView(_error, () {
        this._reload();
      }, () async {
        await this._mailToSupport();
      }) : (_didLoad == true && _sensors.isEmpty == true) ? emptyList() :
      SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 60),
            Image.asset('assets/whiffLogo.png', width: _kImageWidth,
                height: _kImageHeight),
            (_didLoad && _sensors.length > 0) ? Text(AppLocalizations.of(context).translate('onboarding_select_sensor_text'),
                style: TextStyle(fontSize: 22, fontFamily: 'Poppins')) :  Text(AppLocalizations.of(context).translate('onboarding_loading_sensors_text'),
                style: TextStyle(fontSize: 22, fontFamily: 'Poppins')),
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
                          Navigator.pop(context);
                          Navigator.of(context).pushReplacement( MaterialPageRoute(builder: (context) => StatePage()));
                        },
                            child: Text(
                                AppLocalizations.of(context).translate('menu_current_state_button'),
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

  Widget sensorListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.zero,
      itemCount: _sensors.length,
      itemBuilder: (BuildContext context, int index) {
        double temperature =  temperatures[_sensors[index].externalIdentfier.toString()];
        AirState state = states[_sensors[index].externalIdentfier.toString()];
      Measurement measurement = _measurements[_sensors[index].externalIdentfier.toString()];
        if(temperature == null || state == null) {
          _viewModel.fetchMeasurement(_sensors[index]);
        }
        return
          Wrap(
            children:[
              SizedBox(height: 13, width: 100,),
          GestureDetector(child:
          Container(
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(
                    width: 0.5,
                      color: ColorProvider.shared
                          .standardAppButtonBorderColor,),
                      top: BorderSide(
                          width: 0.5,
                          color:  ColorProvider.shared.standardAppButtonBorderColor)),
                  color: ColorProvider.shared.sensorCellBackgroundColor),
              child:
              Column(
                children: [
                  SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 10),
                      //  Expanded(child:
                        Column(children: [
                          Text(AppLocalizations.of(context).translate("sensor_word") + " "  + (index + 1).toString(),
                              style: TextStyle(fontSize: 17,
                                  fontFamily: 'Poppins')),
                          TextButton(
                              onPressed: () {
                                MapsLauncher.launchCoordinates(_sensors[index].locationLat, _sensors[index].locationLon, "Whiff Sensor");
                              },
                              child: Image.asset('assets/room_24px.png', scale: 2))
                                    ],),//),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 7,
                          child:

                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            SizedBox(height: 18),

                            _sensors[index].isInsideBuilding ? Text(AppLocalizations.of(context).translate("device_indoor_sensor"),   textAlign: TextAlign.left,   style: TextStyle(fontSize: 12,
                                fontFamily: 'Poppins',)): Text(AppLocalizations.of(context).translate("device_outdoor_sensor"),    textAlign: TextAlign.left,  style: TextStyle(fontSize: 12,
                                fontFamily: 'Poppins', fontWeight: FontWeight.bold)),

                            Text(
                              AppLocalizations.of(context).translate("device_number_word") +_sensors[index].externalIdentfier.toString(),
                            /*  textAlign: TextAlign.left,*/  style: TextStyle(fontSize: 12,
                              fontFamily: 'Poppins',),), Text(
                              AppLocalizations.of(context).translate("location_word")  + _sensors[index].locationName,
                              /* textAlign: TextAlign.c,*/ maxLines: 2,style: TextStyle(fontSize: 12,
        fontFamily: 'Poppins',))
                          ],),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                            flex: 3,
                            child:
                        Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,

                              children: [
                              SizedBox(height: 45),
                                temperature == null ? Text("- ℃"): Text(  sprintf('%0.0f ℃' , [temperature]) ) ])),
                        SizedBox(width: 15),
                        Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                SizedBox(height: 25),
                                state == null ? CircularProgressIndicator(backgroundColor: ColorProvider.shared.loadingIndicatorCircleColor, valueColor: AlwaysStoppedAnimation<Color>(ColorProvider.shared.standardAppButtonColor)): state == AirState.good ? Image.asset('assets/good_small.png', width: 54,
                                    height: 54): state == AirState.moderate ? Image.asset('assets/moderate_small.png', width: 54,
                                    height: 54) :  state == AirState.bad ?  Image.asset('assets/sad_small.png', width: 54,
                                    height: 54): Image.asset('assets/verysad_small.png', width: 54,
                                    height: 54) ])  ,
                        SizedBox(width: 15),
                      ]),



                  SizedBox(height: 20)

                ],)
          ),
            onTap: () =>
            {
              this.showMeasurementPage(_sensors[index], measurement)
            },
          )]);
      },);
  }


  Widget emptyList() {
    return
         Center(child:
        FailurePage(WhiffError(1002,
            AppLocalizations.of(context).translate('failure_page_empty_sensors_list_message')), () {
          this._reload();
        }, () async {
          await this._mailToSupport();
        })

    );
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
}

