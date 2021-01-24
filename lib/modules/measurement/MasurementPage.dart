import 'package:intl/intl.dart';
import 'dart:async';

import 'package:Whiff/model/Measurement.dart';
import 'package:Whiff/modules/measurement/MeasurementViewModel.dart';
import 'package:Whiff/customView/LoadingIndicator.dart';

import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:flutter/rendering.dart';

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

  MeasurementViewModelContract _viewModel = MeasurementViewModel();

  Measurement _measurement;
  StreamSubscription currentMeasurementSubscription;

  void _popPage() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    currentMeasurementSubscription = _viewModel.currentMeasurement().listen((measurement) {
          this._measurement = measurement;
          this._didLoad = true;
          print("loaded");
          this.setState( () {});
        });

    _viewModel.fetchMeasurement(widget.sensor.externalIdentfier);
  }

  @override
  void deactivate() {
    this.currentMeasurementSubscription.cancel();
    super.deactivate();
  }

  Widget build(BuildContext context)  {

    List<Widget> measurementDataWidget() {

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
              children: [
                SizedBox(width: 70),
                (_measurement != null)
                    ? Text("Temperature: ",
                    style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
                    : SizedBox(),
                SizedBox(width: 10),
                (_measurement != null) ? Text(
                    _measurement.temperature.toString(), style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold)) : SizedBox(),
                SizedBox(width: 10),
                (_measurement != null) ? Text("deegres", style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold)) : SizedBox(),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                SizedBox(width: 105),
                (_measurement != null)
                    ? Text("Pm1 level: ",
                    style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
                    : SizedBox(),
                SizedBox(width: 10),
                (_measurement != null) ? Text(_measurement.pm1Level.toString(),
                    style: TextStyle(fontSize: 17,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold)) : SizedBox(),
                SizedBox(width: 10),
                (_measurement != null) ? Text("ug/m3", style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold)) : SizedBox(),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                SizedBox(width: 90),
                (_measurement != null)
                    ? Text("Pm25 level: ",
                    style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
                    : SizedBox(),
                SizedBox(width: 10),
                (_measurement != null) ? Text(_measurement.pm25level.toString(),
                    style: TextStyle(fontSize: 17,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold)) : SizedBox(),
                SizedBox(width: 10),
                (_measurement != null) ? Text("ug/m3", style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold)) : SizedBox(),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                SizedBox(width: 95),
                (_measurement != null)
                    ? Text("Pm10 level: ",
                    style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
                    : SizedBox(),
                SizedBox(width: 10),
                (_measurement != null) ? Text(_measurement.pm10Level.toString(),
                    style: TextStyle(fontSize: 17,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold)) : SizedBox(),
                SizedBox(width: 10),
                (_measurement != null) ? Text("ug/m3", style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold)) : SizedBox(),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                SizedBox(width: 55),
                (_measurement != null)
                    ? Text("Humidility level: ",
                    style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
                    : SizedBox(),
                SizedBox(width: 10),
                (_measurement != null) ? Text(_measurement.humidity.toString(),
                    style: TextStyle(fontSize: 17,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold)) : SizedBox(),
                SizedBox(width: 10),
                (_measurement != null) ? Text("ug/m3", style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold)) : SizedBox(),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                SizedBox(width: 20),
                (_measurement != null)
                    ? Text("Formaldehyd: level: ",
                    style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
                    : SizedBox(),
                SizedBox(width: 10),
                (_measurement != null) ? Text(
                    _measurement.formaldehyde.toString(), style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold)) : SizedBox(),
                SizedBox(width: 10),
                (_measurement != null) ? Text("ug/m3", style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold)) : SizedBox(),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                SizedBox(width: 97),
                (_measurement != null)
                    ? Text("CO2: level: ",
                    style: TextStyle(fontSize: 17, fontFamily: 'Poppins'))
                    : SizedBox(),
                SizedBox(width: 10),
                (_measurement != null) ? Text(_measurement.co2level.toString(),
                    style: TextStyle(fontSize: 17,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold)) : SizedBox(),
                SizedBox(width: 10),
                (_measurement != null) ? Text("ug/m3", style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold)) : SizedBox(),
              ],
            ),
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
                  alignment: FractionalOffset.bottomCenter,
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                     child: this._didLoad ? Column(children: measurementDataWidget(),) :LoadingIndicator(),
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
