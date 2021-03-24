import 'package:intl/intl.dart';
import 'dart:async';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';

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
  @override
  MeasurementPageState createState() => MeasurementPageState();

  MeasurementPage(Sensor sensor) {
    this.sensor = sensor;
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
    currentMeasurementSubscription = _viewModel.currentMeasurement().listen((measurement) {
          if(measurement != null) {
            this._measurement = measurement;
            this._didLoad = true;
            this.setState(() {});
          }
    });

    errorSubscription = _viewModel.fetchErrorStream().listen((error) {
      if(error != null) {
        this._error = error;
        this.setState(() {});
      }
    });
    _viewModel.fetchMeasurement(widget.sensor.externalIdentfier);
  }

  @override
  void deactivate() {
    this.currentMeasurementSubscription.cancel();
    this.errorSubscription.cancel();
    super.deactivate();
  }

  Widget build(BuildContext context)  {

    List<Widget> measurementDataWidget() {

      final screenWidth = MediaQuery.of(context).size.width;

      return [
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

            Row(
             mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                 children:[Container(height:30, width: screenWidth * 0.5, alignment: Alignment.centerRight, child: Text("Temperature: ",
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

                        Text("℃", style: TextStyle(
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
                children:[Container(height:30, width: screenWidth * 0.5, alignment: Alignment.centerRight, child: Text("Humidity: ",
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
                            fontSize: 17,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold)),
                    SizedBox(width: 5,),

                    Text("%RH", style: TextStyle(
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
                children:[Container(height:30, width: screenWidth * 0.5, alignment: Alignment.centerRight, child: Text("PM10: ",
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
                            fontSize: 17,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold)),
                    SizedBox(width: 5,),

                    Text("μg/m³", style: TextStyle(
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
                children:[Container(height:30, width: screenWidth * 0.5, alignment: Alignment.centerRight, child: Text("PM2.5: ",
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
                            fontSize: 17,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold)),
                    SizedBox(width: 5,),

                    Text("μg/m³", style: TextStyle(
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
                children:[Container(height:30, width: screenWidth * 0.5, alignment: Alignment.centerRight, child: Text("PM1: ",
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
                            fontSize: 17,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold)),
                    SizedBox(width: 5,),

                    Text("μg/m³", style: TextStyle(
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
                children:[Container(height:30, width: screenWidth * 0.5, alignment: Alignment.centerRight, child: Text("CO2: ",
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
                            fontSize: 17,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold)),
                    SizedBox(width: 5,),

                    Text("ppm", style: TextStyle(
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
                children:[Container(height:30, width: screenWidth * 0.5, alignment: Alignment.centerRight, child: Text("Formaldehyde: ",
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
                            fontSize: 17,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold)),
                    SizedBox(width: 5,),

                    Text("μg/m³", style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold))

                  ],)

                  ,)])
          ],
        ),
            // SizedBox(height: 5),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //  //   SizedBox(width: 105),
            //     (_measurement != null)
            //         ? Text("Pm1 level: ",
            //         style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
            //         : SizedBox(),
            //     SizedBox(width: 10),
            //     (_measurement != null) ? Text(_measurement.pm1Level.toString(),
            //         style: TextStyle(fontSize: 17,
            //             fontFamily: 'Poppins',
            //             fontWeight: FontWeight.bold)) : SizedBox(),
            //     SizedBox(width: 10),
            //     (_measurement != null) ? Text("ug/m3", style: TextStyle(
            //         fontSize: 17,
            //         fontFamily: 'Poppins',
            //         fontWeight: FontWeight.bold)) : SizedBox(),
            //   ],
            // ),
            // SizedBox(height: 5),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //    // SizedBox(width: 90),
            //     (_measurement != null)
            //         ? Text("Pm25 level: ",
            //         style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
            //         : SizedBox(),
            //     SizedBox(width: 10),
            //     (_measurement != null) ? Text(_measurement.pm25level.toString(),
            //         style: TextStyle(fontSize: 17,
            //             fontFamily: 'Poppins',
            //             fontWeight: FontWeight.bold)) : SizedBox(),
            //     SizedBox(width: 10),
            //     (_measurement != null) ? Text("ug/m3", style: TextStyle(
            //         fontSize: 17,
            //         fontFamily: 'Poppins',
            //         fontWeight: FontWeight.bold)) : SizedBox(),
            //   ],
            // ),
            // SizedBox(height: 5),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //    // SizedBox(width: 95),
            //     (_measurement != null)
            //         ? Text("Pm10 level: ",
            //         style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
            //         : SizedBox(),
            //     SizedBox(width: 10),
            //     (_measurement != null) ? Text(_measurement.pm10Level.toString(),
            //         style: TextStyle(fontSize: 17,
            //             fontFamily: 'Poppins',
            //             fontWeight: FontWeight.bold)) : SizedBox(),
            //     SizedBox(width: 10),
            //     (_measurement != null) ? Text("ug/m3", style: TextStyle(
            //         fontSize: 17,
            //         fontFamily: 'Poppins',
            //         fontWeight: FontWeight.bold)) : SizedBox(),
            //   ],
            // ),
            // SizedBox(height: 5),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //   //  SizedBox(width: 55),
            //     (_measurement != null)
            //         ? Text("Humidility level: ",
            //         style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
            //         : SizedBox(),
            //     SizedBox(width: 10),
            //     (_measurement != null) ? Text(_measurement.humidity.toString(),
            //         style: TextStyle(fontSize: 17,
            //             fontFamily: 'Poppins',
            //             fontWeight: FontWeight.bold)) : SizedBox(),
            //     SizedBox(width: 10),
            //     (_measurement != null) ? Text("ug/m3", style: TextStyle(
            //         fontSize: 17,
            //         fontFamily: 'Poppins',
            //         fontWeight: FontWeight.bold)) : SizedBox(),
            //   ],
            // ),
            // SizedBox(height: 5),
            // Row(
            //   children: [
            // //    SizedBox(width: 20),
            //     (_measurement != null)
            //         ? Text("Formaldehyd: level: ",
            //         style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
            //         : SizedBox(),
            //     SizedBox(width: 10),
            //     (_measurement != null) ? Text(
            //         _measurement.formaldehyde.toString(), style: TextStyle(
            //         fontSize: 17,
            //         fontFamily: 'Poppins',
            //         fontWeight: FontWeight.bold)) : SizedBox(),
            //     SizedBox(width: 10),
            //     (_measurement != null) ? Text("ug/m3", style: TextStyle(
            //         fontSize: 17,
            //         fontFamily: 'Poppins',
            //         fontWeight: FontWeight.bold)) : SizedBox(),
            //   ],
            // ),
            // SizedBox(height: 5),
            // Row(
            //   children: [
            //     SizedBox(width: 97),
            //     (_measurement != null)
            //         ? Text("CO2: level: ",
            //         style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
            //         : SizedBox(),
            //     SizedBox(width: 10),
            //     (_measurement != null) ? Text(_measurement.co2level.toString(),
            //         style: TextStyle(fontSize: 17,
            //             fontFamily: 'Poppins',
            //             fontWeight: FontWeight.bold)) : SizedBox(),
            //     SizedBox(width: 10),
            //     (_measurement != null) ? Text("ug/m3", style: TextStyle(
            //         fontSize: 17,
            //         fontFamily: 'Poppins',
            //         fontWeight: FontWeight.bold)) : SizedBox(),
            //   ],
            // ),
          ];
      }

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
                        _viewModel.fetchMeasurement(widget.sensor.externalIdentfier);
                     },  () async {
                         await this._mailToSupport();
                     }): this._didLoad ? Column(children: measurementDataWidget(),) :LoadingIndicator(),
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
}
