import 'dart:async';
import 'package:Whiff/modules/historical/HistoricalPage.dart';
import 'package:Whiff/modules/sensorManager/SensorManagerViewModel.dart';
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
import 'package:Whiff/modules/secondWelcome/secondWelcome.dart';
class SensorManagerPage extends StatefulWidget {
  @override
  SensorManagerPageState createState() => SensorManagerPageState();
}

class SensorManagerPageState extends State<SensorManagerPage> {
  final double _kImageWidth = 120;
  final double _kImageHeight = 60;
  final double _kButtonCornerRadius = 10;

  bool _didLoad = false;

  SensorManagerViewModelContract _viewModel = SensorManagerViewModel();

  StreamSubscription sensorListSubscription;

  StreamSubscription sensorListErrorSubscription;

  List<Sensor> _sensors = [];

  WhiffError _error;

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
    _error = null;
    _didLoad = false;
    setState(() {});
    _viewModel.fetchSensors();
  }

  @override
  void deactivate() {
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

  var _firstFocusNode = FocusNode();


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
      }) :

    SingleChildScrollView(
    reverse: true,
    child: Column(
            children: [
              SizedBox(height: 40),
              Image.asset('assets/whiffLogo.png', width: _kImageWidth,
                  height: _kImageHeight),
              (_didLoad && _sensors.length > 0) ? Text(AppLocalizations.of(context).translate('onboarding_select_sensor_text'),
                  style: TextStyle(fontSize: 22, fontFamily: 'Poppins')) :  Text(AppLocalizations.of(context).translate('onboarding_loading_sensors_text'),
                  style: TextStyle(fontSize: 22, fontFamily: 'Poppins')),
              _didLoad ? SizedBox(height: 20) : SizedBox(height: 100),
              _didLoad ? _sensors.length > 0 ? sensorListView(): emptyList() : LoadingIndicator(),
              SizedBox(height: 10,),
              Text("Please, write down the key sensor number",  style: TextStyle(fontSize: 14, fontFamily: 'Poppins')),
              SizedBox(height: 10,),

              Padding(padding: EdgeInsets.only(left: 20, right: 20), child:
                TextField(
                    focusNode: _firstFocusNode,
                    onChanged: (value){
                      _viewModel.setSensorPreSharedKey(value);
                    },
                    onEditingComplete: ()  async {
                      _firstFocusNode.unfocus();
                      _viewModel.requestAddSensor();

                    },
                    obscureText: false,
                    decoration: InputDecoration(
                      hintText: "Sensor preshared key",
                    )
                )),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
              Container(
              width: MediaQuery.of(context).size.width - 2*20,
              height: 40,
              child:
              RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_kButtonCornerRadius),
                      side:BorderSide(color: ColorProvider.shared.standardAppButtonBorderColor)
                  ),
                  onPressed: () {
                    _viewModel.requestAddSensor();
                  },
                  color: ColorProvider.shared.standardAppButtonColor,
                  textColor: ColorProvider.shared.standardAppButtonTextColor,
                  child: Text("Add sensor")

              ))]),
              SizedBox(height: 20,),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
            Container(
                 width: MediaQuery.of(context).size.width - 2*20,
                 height: 40,
                 child:
              RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_kButtonCornerRadius),
                      side:BorderSide(color: ColorProvider.shared.standardAppButtonBorderColor)
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => SecondWelcomePage(false)));
                  },
                  color: ColorProvider.shared.standardAppButtonColor,
                  textColor: ColorProvider.shared.standardAppButtonTextColor,
                  child: Text("Proceed")

              ))])

            ],
          ),
    )),
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
                                        SizedBox(height: 45),])),
                              SizedBox(width: 15),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    SizedBox(height: 25),
                                  ])  ,
                              SizedBox(width: 15),
                            ]),



                        SizedBox(height: 20)

                      ],)
                ),
                  onTap: () =>
                  {
                  },
                )]);
      },);
  }


  Widget emptyList() {
    return
      Center(child:
      FailurePage(WhiffError(1002,
          AppLocalizations.of(context).translate('sensor_manager_empty_list_description')),
              () {},
              () {},
          hideButtons: true,)

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

