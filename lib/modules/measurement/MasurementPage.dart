import 'package:Whiff/helpers/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Whiff/model/MeasurementType.dart';

import 'package:Whiff/model/Measurement.dart';
import 'package:Whiff/modules/measurement/MeasurementViewModel.dart';
import 'package:Whiff/customView/LoadingIndicator.dart';

import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:flutter/rendering.dart';
import 'package:Whiff/customView/FailurePage.dart';
import 'package:Whiff/model/WhiffError.dart';


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
        to: ['to@example.com'],
        cc: ['cc1@example.com', 'cc2@example.com'],
        subject: 'mailto example subject',
        body: 'mailto example body',
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
          Column(children: [
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
            Expanded(
                child: Align(
                  alignment: FractionalOffset.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                     child: (this._error != null) ? FailurePage(this._error, (){
                        this._didLoad = false;
                        this._error = null;
                        this.setState(() {});
                        _viewModel.fetchMeasurement(widget.sensor);
                     },  () async {
                         await this._mailToSupport();
                     }): this._didLoad ? Column(children:[measurementHeaderWidget(), measurementDataWidget()],):LoadingIndicator(),
                  ),
                ),
                ),
          ],
          );
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
        body: content(),
      );
  }


  Widget measurementHeaderWidget() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(children: [
      SizedBox(height: 40),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (_measurement != null)
              ? Text(_dateformatter.format(_measurement.date),
              style: TextStyle(fontSize: 21, fontFamily: 'Poppins'))
              : SizedBox(),
        ],
      ),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (_measurement != null)
              ? Text(_hourformatter.format(_measurement.date),
              style: TextStyle(fontSize: 21, fontFamily: 'Poppins'))
              : SizedBox(),
        ],
      ),
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (_measurement != null)
              ? Text(widget.sensor.name,
              style: TextStyle(fontSize: 21, fontFamily: 'Poppins'))
              : SizedBox(),
        ],
      ),
      SizedBox(height: 20),


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
                          _measurement.temperature.toString(),
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
                          _measurement.humidity.toString(),
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
                          _measurement.pm10Level.toString(),
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
                          _measurement.pm25level.toString(),
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
                          _measurement.pm1Level.toString(),
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
                          _measurement.co2level.toString(),
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
                          _measurement.formaldehyde.toString(),
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
}
