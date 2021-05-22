import 'package:Whiff/helpers/app_localizations.dart';
import 'package:Whiff/model/AirState.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Whiff/model/MeasurementType.dart';
import 'package:sprintf/sprintf.dart';

import 'package:Whiff/model/Measurement.dart';
import 'package:Whiff/modules/measurement/MeasurementViewModel.dart';
import 'package:Whiff/customView/LoadingIndicator.dart';
import 'package:share/share.dart';
import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:flutter/rendering.dart';
import 'package:Whiff/customView/FailurePage.dart';
import 'package:Whiff/model/WhiffError.dart';
import 'package:maps_launcher/maps_launcher.dart';


class MeasurementPage extends StatefulWidget {
  Sensor sensor;
  Measurement measurement;
  @override
  MeasurementPageState createState() => MeasurementPageState();

  MeasurementPage(Sensor sensor, Measurement measurement) {
    this.sensor = sensor;
    this.measurement = measurement;
  }
}

class MeasurementPageState extends State<MeasurementPage>  {

  bool _didLoad = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final double _kImageWidth = 120;
  final double _kImageHeight = 60;
  final double _kStandardInset = 15;

  final DateFormat _dateformatter = DateFormat('EEEE, dd MMMM');
  final DateFormat _exportdateformatter = DateFormat('dd MMMM yyyy, HH:mm');

  final DateFormat _hourformatter = DateFormat('HH:mm');

  final MeasurementViewModelContract _viewModel = MeasurementViewModel();

  Measurement _measurement;
  WhiffError _error;

  StreamSubscription currentMeasurementSubscription;
  StreamSubscription errorSubscription;

  void _popPage() {
    Navigator.of(context).pop();
  }

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      print(url);
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
      body: 'Provide here info about the issue',
    );

      await _launchURL(mailtoLink.toString());
  }



  @override
  void initState() {
    super.initState();
    _measurement = widget.measurement;
    if(_measurement != null) {
      this._didLoad = true;
    }
    currentMeasurementSubscription = _viewModel.currentMeasurement().listen((measurement) {
          if(measurement != null ) {
            if(measurement.deviceNumber == widget.sensor.externalIdentfier) {
              this._measurement = measurement;
              this._didLoad = true;
              this.setState(() {});
            }
          }
    });

    errorSubscription = _viewModel.fetchErrorStream().listen((error) {
      if(error != null) {
        this._error = error;
        this.setState(() {});
      }
    });
    _viewModel.fetchMeasurement(widget.sensor);
  }

  @override
  void deactivate() {
    this.currentMeasurementSubscription.cancel();
    this.errorSubscription.cancel();
    super.deactivate();
  }


  Widget build(BuildContext context)  {
      Widget content() {
        return
          ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(0),
              children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 30),
                ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/whiffLogo.png', width: _kImageWidth,
                    height: _kImageHeight),
              ],
            ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                     child: (this._error != null) ? FailurePage(this._error, (){
                        this._didLoad = false;
                        this._error = null;
                        this.setState(() {});
                        _viewModel.fetchMeasurement(widget.sensor);
                     },  () async {
                         await this._mailToSupport();
                     }): this._didLoad ? Column(children:[measurementHeaderWidget(), measurementDataWidget(),measurementFooterWidget(),
                       Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: <Widget>[
                             TextButton(onPressed: (){
                               _launchURL(_viewModel.getPrivacyPolicy());

                             }, child: Text(AppLocalizations.of(context).translate('login_login_privacy_policy'),  style: TextStyle(color: ColorProvider.shared.standardAppButtonColor))),
                           ]),
                       Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: <Widget>[
                             TextButton(onPressed: (){
                               _launchURL(_viewModel.getTermsOfServiceUrl());
                             }, child: Text(AppLocalizations.of(context).translate('login_login_terms_of_service'),  style: TextStyle(color: ColorProvider.shared.standardAppButtonColor))),
                           ])],):Column(children:[SizedBox(height: 125,), LoadingIndicator() ])
                  ),

          ]);

      }

      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent,
          elevation:0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios,
              color: ColorProvider.shared.standardAppButtonColor),
            onPressed: (){
              this._popPage();
            },
          ),
        ),
        backgroundColor: ColorProvider.shared.standardAppBackgroundColor,
        extendBodyBehindAppBar:true,
        body: content()
      );
  }


  Widget measurementHeaderWidget() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(children: [
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 30,),
          (_measurement != null)
              ? Text(_dateformatter.format(_measurement.date),
              style: TextStyle(fontSize: 21, fontFamily: 'Poppins'))
              : SizedBox(),
          SizedBox(width: 10,),
          (_measurement != null)
              ? Text(_hourformatter.format(_measurement.date),
              style: TextStyle(fontSize: 21, fontFamily: 'Poppins'))
              : SizedBox()
        ],
      ),
        Flex(
          direction:  Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.start,
        children: [
    Flexible(flex: 6,child:Column(
              crossAxisAlignment:  CrossAxisAlignment.start,

              children: [
      SizedBox(height: 5),
      Row(  mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 30),
          (_measurement != null)
              ? Text(widget.sensor.name,
              style: TextStyle(fontSize: 21, fontFamily: 'Poppins'))
              : SizedBox(),
        ],
      ),
      SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 30),
          (_measurement != null)
              ? Text(AppLocalizations.of(context).translate("measurement_device_number_label") + widget.sensor.externalIdentfier.toString(),
              style: TextStyle(fontSize: 16, fontFamily: 'Poppins'))
              : SizedBox(),
        ],
      ),
                // _sensors[index].isInsideBuilding ? Text(AppLocalizations.of(context).translate("device_indoor_sensor"),   textAlign: TextAlign.left,   style: TextStyle(fontSize: 12,
                //   fontFamily: 'Poppins',))
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 30),
                      Text(widget.measurement.isInsideBuilding ? AppLocalizations.of(context).translate("measurement_indoor_sensor_label") : AppLocalizations.of(context).translate("measurement_outdoor_sensor_label"),
                          style: TextStyle(fontSize: 16, fontFamily: 'Poppins'))
                      ]
                ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 30),
          (_measurement != null)
              ? Flexible(child:Text( AppLocalizations.of(context).translate("measurement_location_label") + widget.sensor.locationName, maxLines: 2,
              style: TextStyle(fontSize: 16, fontFamily: 'Poppins')))
              : SizedBox(),
        ],
      ),
      SizedBox(height: 20),

    ]),),    SizedBox(width: 10),

          Expanded(flex: 4, child:Column(children: [Container(height: 100, width: 100, child: _measurement.getState() == AirState.good ?  Image.asset('assets/good_small.png'):  _measurement.getState() == AirState.moderate ?  Image.asset('assets/moderate_small.png') : _measurement.getState() == AirState.bad ?  Image.asset('assets/sad_small.png') :  Image.asset('assets/verysad_small.png')  ,)],),),

        ]),

    ]);
  }

  Widget measurementDataWidget() {

    final screenWidth = MediaQuery.of(context).size.width;

    return

      Container( //color: Colors.white,
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
        children:[
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[Container(height:30, width: screenWidth * 0.5, alignment: Alignment.centerRight, child: Text((AppLocalizations.of(context).translate(MeasurementType.temperature.stringName())),
                      textAlign: TextAlign.end,

                      style: TextStyle(fontSize: 17,  fontFamily: 'Poppins')))]
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[Container(
                    alignment: Alignment.centerLeft,
                    height:30, width: screenWidth * 0.5, child:
                  Row(
                    children: [
                      SizedBox(width: 10,),
                      Text(
                          sprintf('%0.2f' , [_measurement.temperature]),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 5,),

                      Text(AppLocalizations.of(context).translate(MeasurementType.temperature.unitName()), style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold))

                    ],)

                    ,)])
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[Container(height:30, width: screenWidth * 0.5, alignment: Alignment.centerRight, child: Text((AppLocalizations.of(context).translate(MeasurementType.humidity.stringName())),
                      textAlign: TextAlign.end,

                      style: TextStyle(fontSize: 17,  fontFamily: 'Poppins')))]
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[Container(
                    alignment: Alignment.centerLeft,
                    height:30, width: screenWidth * 0.5, child:
                  Row(
                    children: [
                      SizedBox(width: 10,),
                      Text(
                          sprintf('%0.0f' , [ _measurement.humidity]),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: widget.sensor.isInsideBuilding == true ? _measurement.humidityNorm().levelColor: ColorProvider.shared.standardTextColor,
                              fontSize: 17,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 5,),

                      Text(AppLocalizations.of(context).translate(MeasurementType.humidity.unitName()), style: TextStyle(
                          color: widget.sensor.isInsideBuilding == true ? _measurement.humidityNorm().levelColor: ColorProvider.shared.standardTextColor,
                          fontSize: 17,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold))

                    ],)

                    ,)])
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[Container(height:30, width: screenWidth * 0.5, alignment: Alignment.centerRight, child: Text(AppLocalizations.of(context).translate(MeasurementType.pm10level.stringName()),
                      textAlign: TextAlign.end,

                      style: TextStyle(fontSize: 17,  fontFamily: 'Poppins')))]
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[Container(
                    alignment: Alignment.centerLeft,
                    height:30, width: screenWidth * 0.5, child:
                  Row(
                    children: [
                      SizedBox(width: 10,),
                      Text(
                          sprintf('%0.2f' , [ _measurement.pm10Level]),

                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: _measurement.pm10LevelNorm().levelColor,
                              fontSize: 17,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 5,),

                      Text(AppLocalizations.of(context).translate(MeasurementType.pm10level.unitName()), style: TextStyle(
                          color: _measurement.pm10LevelNorm().levelColor,
                          fontSize: 17,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold))

                    ],)

                    ,)])
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[Container(height:30, width: screenWidth * 0.5, alignment: Alignment.centerRight, child: Text((AppLocalizations.of(context).translate(MeasurementType.pm25level.stringName())),
                      textAlign: TextAlign.end,

                      style: TextStyle(fontSize: 17,  fontFamily: 'Poppins')))]
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[Container(
                    alignment: Alignment.centerLeft,
                    height:30, width: screenWidth * 0.5, child:
                  Row(
                    children: [
                      SizedBox(width: 10,),
                      Text(
                          sprintf('%0.2f' , [ _measurement.pm25level]),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: _measurement.pm25LevelNorm().levelColor,
                              fontSize: 17,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 5,),

                      Text(AppLocalizations.of(context).translate(MeasurementType.pm25level.unitName()), style: TextStyle(
                          color: _measurement.pm25LevelNorm().levelColor,
                          fontSize: 17,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold))

                    ],)

                    ,)])
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[Container(height:30, width: screenWidth * 0.5, alignment: Alignment.centerRight, child: Text((AppLocalizations.of(context).translate(MeasurementType.pm1level.stringName())),
                      textAlign: TextAlign.end,

                      style: TextStyle(fontSize: 17,  fontFamily: 'Poppins')))]
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[Container(
                    alignment: Alignment.centerLeft,
                    height:30, width: screenWidth * 0.5, child:
                  Row(
                    children: [
                      SizedBox(width: 10,),
                      Text(
                          sprintf('%0.2f' , [ _measurement.pm1Level]),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: _measurement.pm1LevelNorm().levelColor,
                              fontSize: 17,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 5,),

                      Text(AppLocalizations.of(context).translate(MeasurementType.pm1level.unitName()), style: TextStyle(
                          color: _measurement.pm1LevelNorm().levelColor,
                          fontSize: 17,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold))

                    ],)

                    ,)])
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[Container(height:30, width: screenWidth * 0.5, alignment: Alignment.centerRight, child: Text((AppLocalizations.of(context).translate(MeasurementType.co2level.stringName())),
                      textAlign: TextAlign.end,

                      style: TextStyle(fontSize: 17,  fontFamily: 'Poppins')))]
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[Container(
                    alignment: Alignment.centerLeft,
                    height:30, width: screenWidth * 0.5, child:
                  Row(
                    children: [
                      SizedBox(width: 10,),
                      Text(
                          sprintf('%0.2f' , [ _measurement.co2level]),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: widget.sensor.isInsideBuilding == true ? _measurement.co2LevelNorm().levelColor : ColorProvider.shared.standardTextColor,
                              fontSize: 17,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 5,),

                      Text((AppLocalizations.of(context).translate(MeasurementType.co2level.unitName())), style: TextStyle(
                          color: widget.sensor.isInsideBuilding == true ? _measurement.co2LevelNorm().levelColor : ColorProvider.shared.standardTextColor,
                          fontSize: 17,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold))

                    ],)

                    ,)])
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[Container(height:30, width: screenWidth * 0.5, alignment: Alignment.centerRight, child: Text((AppLocalizations.of(context).translate(MeasurementType.formaldehyde.stringName())),
                      textAlign: TextAlign.end,

                      style: TextStyle(fontSize: 17,  fontFamily: 'Poppins')))]
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[Container(
                    alignment: Alignment.centerLeft,
                    height:30, width: screenWidth * 0.5, child:
                  Row(
                    children: [
                      SizedBox(width: 10,),
                      Text(
                          sprintf('%0.2f' , [ _measurement.formaldehyde]),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: widget.sensor.isInsideBuilding == true ? _measurement.formaldehydeLevelNorm().levelColor : ColorProvider.shared.standardTextColor,
                              fontSize: 17,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 5,),

                      Text((AppLocalizations.of(context).translate(MeasurementType.formaldehyde.unitName())), style: TextStyle(
                          fontSize: 17,
                          color: widget.sensor.isInsideBuilding == true ? _measurement.formaldehydeLevelNorm().levelColor : ColorProvider.shared.standardTextColor,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold))

                    ],)

                    ,)])
            ],
          ),
          SizedBox(height: 10,),
        ]));
  }

  Widget measurementFooterWidget() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 15),

        Row(

          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          TextButton(
              onPressed: () {
                MapsLauncher.launchCoordinates(widget.sensor.locationLat, widget.sensor.locationLon, AppLocalizations.of(context).translate("measurement_whiff_sensor_label"));
              },
              child: Image.asset('assets/Measurement_Page_Map_Button.png', scale: 3)),
          TextButton(
                onPressed: () {
                  this._didLoad = false;
                  this._error = null;
                  this.setState(() {});
                  _viewModel.fetchMeasurement(widget.sensor);
              },
              child: Image.asset('assets/refresh_page_button.png', scale: 3)),
          TextButton(
              onPressed: () {
                Share.share("The Whiff measurement \nmade: " +  _exportdateformatter.format(_measurement.date) + "\ndevice number: " + widget.sensor.externalIdentfier.toString() + "\ndevice location: " + widget.sensor.locationName + (widget.sensor.isInsideBuilding ? "\nindoor sensor" : "\noutdoor sensor") + "\nair state: " + _measurement.getState().string(context) + "\ntemperature:" +  sprintf('%0.2f' , [_measurement.temperature])  + (AppLocalizations.of(context).translate(MeasurementType.temperature.unitName())) +"\nhumidity: " + sprintf('%0.0f' , [_measurement.humidity]) + (AppLocalizations.of(context).translate(MeasurementType.humidity.unitName())) + "\npm1Level: " + sprintf('%0.2f' , [_measurement.pm1Level]) + (AppLocalizations.of(context).translate(MeasurementType.pm1level.unitName())) + "\npm10Level: " + sprintf('%0.2f' , [_measurement.pm10Level]) + (AppLocalizations.of(context).translate(MeasurementType.pm10level.unitName())) + "\npm25Level: " + sprintf('%0.2f' , [_measurement.pm25level]) + (AppLocalizations.of(context).translate(MeasurementType.pm25level.unitName())) + "\nco2Level: " + sprintf('%0.2f' , [_measurement.co2level]) +  (AppLocalizations.of(context).translate(MeasurementType.co2level.unitName())) + "\nformaldehyde: " + sprintf('%0.2f' , [_measurement.formaldehyde]) + (AppLocalizations.of(context).translate(MeasurementType.formaldehyde.unitName())) +  "\nGenerated by WhiffApp " + _exportdateformatter.format(_measurement.date) + "\nhttp://whiff.zone" );


              },
              child: Image.asset('assets/share_page_button.png', scale: 3)),
        ],),

    SizedBox(height: 10,),
    Row(

    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
        Container(//color: Colors.white,
          decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(
                    width: 0.5,
                    color: ColorProvider.shared
                        .standardAppButtonBorderColor,),
                  left: BorderSide(
                    width: 0.5,
                    color: ColorProvider.shared
                        .standardAppButtonBorderColor,),
                  bottom: BorderSide(
                    width: 0.5,
                    color: ColorProvider.shared
                        .standardAppButtonBorderColor,),
                  top: BorderSide(
                      width: 0.5,
                      color: ColorProvider.shared.standardAppButtonBorderColor)),
              color: ColorProvider.shared.sensorCellBackgroundColor),
          child:

          Column( crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Row(children:[
                  SizedBox(width: 10,),
                  Text(
                      AppLocalizations.of(context).translate("measurement_page_legend_title"),
                      textAlign: TextAlign.start,

                      style: TextStyle(
                          color: widget.sensor.isInsideBuilding == true ? _measurement.formaldehydeLevelNorm().levelColor : ColorProvider.shared.standardTextColor,
                          fontSize: 17,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold))
                ]),
                Row(crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:[
                      SizedBox(width: 10,),
                      Text(AppLocalizations.of(context).translate("measurement_page_legend_first_postion"),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: ColorProvider.shared.measurumentGoodLevel,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold)), SizedBox(width: 10,),]),
                Row(crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:[
                      SizedBox(width: 10,),
                      Text(
                          AppLocalizations.of(context).translate("measurement_page_legend_second_postion"),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: ColorProvider.shared.measurumentModerateLevel,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold)), SizedBox(width: 10,),]),
                Row(crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:[
                      SizedBox(width: 10,),
                      Text(
                          AppLocalizations.of(context).translate("measurement_page_legend_third_postion"),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: ColorProvider.shared.measurumentBadLevel,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold)),  SizedBox(width: 10,),]),
                Row(crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:[
                      SizedBox(width: 10,),
                      Text(
                          AppLocalizations.of(context).translate("measurement_page_legend_fourth_postion"),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: ColorProvider.shared.measurumentVeryBadLevel,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold)),  SizedBox(width: 10,),])

              ]
          ),)]),
    ],);
  }
}
