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
  bool isInRegistationFlow;
  SensorManagerPage(this.isInRegistationFlow){}
}

class SensorManagerPageState extends State<SensorManagerPage> {
  final double _kImageWidth = 120;
  final double _kImageHeight = 60;
  final double _kButtonCornerRadius = 10;

  bool _didLoad = false;
  bool _didAddSensor = false;

  SensorManagerViewModelContract _viewModel = SensorManagerViewModel();

  StreamSubscription sensorListSubscription;

  StreamSubscription sensorListErrorSubscription;

  StreamSubscription sensorAddSubscription;

  var _firstTextfieldController = TextEditingController();

  var _secondTextfieldController = TextEditingController();

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
      this._didAddSensor = false;
      _secondTextfieldController.clear();
      _firstTextfieldController.clear();
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

    sensorAddSubscription = _viewModel.sensorAddError().listen((error) {
        _didAddSensor = false;
        _secondTextfieldController.clear();

        if(error.errorMessage != null) {
          showAlert(context, error.errorMessage);
        }
        this.setState(() {});
    });
    _viewModel.fetchSensors();
  }

  var _firstFocusNode = FocusNode();
  var _secondFocusNode = FocusNode();

  Widget build(BuildContext context) {

    return WillPopScope(child:
    Scaffold(
    appBar: AppBar(backgroundColor: Colors.transparent,
        elevation:0,
      leading: widget.isInRegistationFlow ? Opacity(opacity: 0.0): IconButton(icon: Icon(Icons.arrow_back_ios,
          color: ColorProvider.shared.standardAppButtonColor),
        onPressed: (){
          this._popPage();
        },
      )),
      extendBodyBehindAppBar: true,
      backgroundColor: ColorProvider.shared.standardAppBackgroundColor,
      body:
      (_error != null) ? failureView(_error, () {
        this._reload();
      }, () async {
        await this._mailToSupport();
      }) :
    Column(
            children: [
              SizedBox(height: MediaQuery.of(context).viewPadding.top + 20),
              Text(AppLocalizations.of(context).translate("sensor_manager_add_sensor_text"),  style: TextStyle(fontSize: 17, fontFamily: 'Poppins')),
              SizedBox(height: 15,),
              Text(AppLocalizations.of(context).translate("sensor_manager_subtitle_text"),  style: TextStyle(fontSize: 14, fontFamily: 'Poppins')),
              SizedBox(height: 10,),
              Padding(padding: EdgeInsets.only(left: 20, right: 20), child:
              TextFormField(
                  focusNode: _firstFocusNode,
                  controller: _firstTextfieldController ,
                  onChanged: (value){
                    _viewModel.setSensorNumber(value);
                  },
                  onEditingComplete: () async {
                    _secondFocusNode.requestFocus();
                  },
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate("sensor_manager_sensor_number_text"),
                  )
              )),
              SizedBox(height: 10,),
              Padding(padding: EdgeInsets.only(left: 20, right: 20), child:
              TextFormField(
                  focusNode: _secondFocusNode,
                  controller: _secondTextfieldController,
                  onChanged: (value){
                    _viewModel.setSensorKey(value);
                  },
                  onEditingComplete: () async {
                    _secondFocusNode.unfocus();
                    _firstFocusNode.unfocus();
                    _didAddSensor = true;
                    _viewModel.requestAddSensor();
                    setState(() {});
                  },
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate("sensor_manager_sensor_key_text"),
                  )
              )),
              SizedBox(height: 10,),

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
                              _secondFocusNode.unfocus();
                              _firstFocusNode.unfocus();
                              _didAddSensor = true;
                              _viewModel.requestAddSensor();
                              setState(() {});
                            },
                            color: ColorProvider.shared.standardAppButtonColor,
                            textColor: ColorProvider.shared.standardAppButtonTextColor,
                            child: Text(AppLocalizations.of(context).translate("sensor_manager_add_sensor_text"))

                        ))]),

              SizedBox(height: 20),
              _sensors.isNotEmpty ? Text(AppLocalizations.of(context).translate("sensor_manager_your_sensors_text")) : SizedBox(height: 1,width: 1,),

              _didLoad ? SizedBox(height: 10) : SizedBox(height: 100),
              _didLoad == true && _didAddSensor == false ? _sensors.length > 0 ? sensorListView() : emptyList() : Expanded(child:LoadingIndicator()),
              SizedBox(height: 10,),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    widget.isInRegistationFlow ?
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
                              if(_sensors.isNotEmpty) {
                                if (widget.isInRegistationFlow == true) {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (context) =>
                                          SecondWelcomePage(false)));
                                }
                              } else {
                                ensureContinue(context, () {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (context) =>
                                          SecondWelcomePage(false)));
                                });
                              }
                            },
                            color: ColorProvider.shared.standardAppButtonColor,
                            textColor: ColorProvider.shared.standardAppButtonTextColor,
                            child: Text(AppLocalizations.of(context).translate("sensor_manager_continue_button_text"))

                        )):SizedBox()]) ,
              SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
            ],
          ),
    ),
      onWillPop: () async => false,
    );
  }

  Widget sensorListView() {
    return
      Expanded(child:
      ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 10),
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
                              Column(children: [
                                Text(AppLocalizations.of(context).translate("sensor_word") + " "  + (index + 1).toString(),
                                    style: TextStyle(fontSize: 17,
                                        fontFamily: 'Poppins')),
                                TextButton(
                                    onPressed: () {
                                      MapsLauncher.launchCoordinates(_sensors[index].locationLat, _sensors[index].locationLon, AppLocalizations.of(context).translate("sensor_manager_whiff_sensor_label"));
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

                                        SizedBox(height: 30,),
                                        TextButton(onPressed: () {
                                          _didAddSensor = true;
                                          ensureDelete(context, (){
                                            _viewModel.requestDeleteSensor(_sensors[index].externalIdentfier.toString());
                                            setState(() {});
                                          });

                                        }, child:


                                        Icon(
                                          Icons.delete_outlined,
                                          color: ColorProvider.shared.standardAppButtonColor,

                                        ),
                                        )

                                        ])),
                              SizedBox(width: 15),
                            ]),



                        SizedBox(height: 20)

                      ],)
                ),
                  onTap: () =>
                  {
                  },
                )]);
      },));
  }


  Widget emptyList() {
    return
    Expanded(child:
      Column(
        children: [
        Text( AppLocalizations.of(context).translate("failure_page_empty_sensors_list_title"), style: TextStyle(fontSize: 17, fontFamily: 'Poppins')),
        SizedBox(height: 10,),
        Text(AppLocalizations.of(context).translate('sensor_manager_empty_list_description'), style: TextStyle(fontSize: 14, fontFamily: 'Poppins'))],
          // FailurePage(WhiffError(1002,
          //     ,
          //         () {},
          //         () {},
          //     hideButtons: true,)

      //     child:


      ));
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

  void _popPage() {
    Navigator.of(context).pop();
  }

  void ensureContinue(BuildContext context, VoidCallback YesPressedCallback) {
    Widget yesButton = TextButton(
      child: Text(AppLocalizations.of(context).translate("sensor_manager_whiff_yes_answer")),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget noButton = TextButton(
      child: Text(AppLocalizations.of(context).translate("sensor_manager_whiff_no_answer")),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(AppLocalizations.of(context).translate("sensor_manager_whiff_sensor_warning_text")),
        actions: [
          yesButton, noButton
        ],
      ),
    );
  }

  void ensureDelete(BuildContext context, VoidCallback YesPressedCallback ) {
    Widget yesButton = TextButton(
      child: Text(AppLocalizations.of(context).translate("sensor_manager_whiff_yes_answer")),
      onPressed: () {
        YesPressedCallback();
        Navigator.of(context).pop();
      },
    );

    Widget noButton = TextButton(
      child: Text(AppLocalizations.of(context).translate("sensor_manager_whiff_no_answer")),
      onPressed: () {

        Navigator.of(context).pop();
      },
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(AppLocalizations.of(context).translate("sensor_manager_whiff_delete_sensor_warning_text")),
        actions: [
          yesButton, noButton
        ],
      ),
    );
  }

}

