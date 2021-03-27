import 'dart:async';
import 'package:Whiff/model/Measurement.dart';
import 'package:intl/intl.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:Whiff/modules/historical/HistoricalViewModel.dart';
import 'package:Whiff/modules/onboarding/OnboardingPage.dart';
import 'package:Whiff/modules/accountSettings/AccountSettingsPage.dart';
import 'package:Whiff/model/MeasurementType.dart';
import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:Whiff/helpers/app_localizations.dart';
import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class HistoricalPage extends StatefulWidget {
  @override
  HistoricalPageState createState() => HistoricalPageState();
}

class HistoricalPageState extends State<HistoricalPage> {
  final AutheticatingServicing authenticationService = AutheticationService.shared;
  final DateFormat kDateFormat = DateFormat("dd MMM yy");

  List<charts.Series<dynamic, DateTime>> seriesList = [];

  HistoricalViewModelContract _viewModel = HistoricalViewModel();

  StreamSubscription onboardingState;

  Sensor _selectedSensor;
  List<Sensor> _sensors = [];

  StreamSubscription _mesurementTypeSubscription;
  StreamSubscription _dateRangeSubscription;
  StreamSubscription _sensorListSubscription;
  StreamSubscription _sensorSelectedSubscription;
  StreamSubscription _chartDataSubscription;


  MeasurementType _currentMeasurementType = MeasurementType.temperature;

  DateTimeRange range =  DateTimeRange(
      end: DateTime.now(),
      start:DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day - 13)

  );


  Future<void> _selectDate(BuildContext context) async {
    DateTimeRange picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      initialDateRange: range
    );
    if(picked != null) {
      _viewModel.setTimeRange(picked);
    };
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



    _mesurementTypeSubscription = _viewModel.currentMeasurementType().listen((measurementType) {
      _currentMeasurementType = measurementType;
      setState(() {});
    });

    _dateRangeSubscription = _viewModel.currentDateRange().listen((dateRange) {
      range = dateRange;
      setState(() {});
    });

    _sensorListSubscription = _viewModel.sensorsList().listen((sensorList) {
      _sensors = sensorList;
      _selectedSensor = sensorList.first;
      _viewModel.setSensor(_selectedSensor);
      setState(() {});
    });

    _sensorSelectedSubscription = _viewModel.selectedSensor().listen((sensor) {
      _selectedSensor = sensor;
      setState(() {});
    });

    _chartDataSubscription = _viewModel.chartData().listen((chartData) {
      seriesList = chartData;
      print("test");
      setState(() {});
    });
    _viewModel.fetchSensors();
    _viewModel.setTimeRange(range);
  }

  @override
  void deactivate() {
    this.onboardingState.cancel();
    super.deactivate();
  }

  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: ColorProvider.shared.standardAppBackgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
              color: ColorProvider.shared.standardAppLeftMenuBackgroundColor)),
      body:
      SingleChildScrollView(child: Column(children: [
        SizedBox(height: 100,),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [ Text("Select Sensor",
              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.black,
                  fontSize: 22,
                  fontFamily: 'Poppins')),
          ],),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            sensorSelector(context),
          ],),
        Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [ Text("Select Date Range",
            textAlign: TextAlign.center,

            style: TextStyle(color: Colors.black,
                fontSize: 22,
                fontFamily: 'Poppins')),
      ],),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          dateRangeSelector(context),
        ],),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [ Text("Select Measurement type",
              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.black,
                  fontSize: 22,
                  fontFamily: 'Poppins')),
          ],),

        Row( mainAxisAlignment: MainAxisAlignment.center, children: [
          measerementSelector(context),
        ],),
        SizedBox(height: 30,),
        Row( mainAxisAlignment: MainAxisAlignment.center, children: [
          chart(context),
        ],),
      ],) ,),



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
                          Navigator.of(context).pushReplacement( MaterialPageRoute(builder: (context) => OnboardingPage()));
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
                          Navigator.of(context).pop();
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

  Widget measerementSelector(BuildContext context) {
    return
      Container(
          width: 200,
          alignment: Alignment.center,
          color: ColorProvider.shared.standardAppButtonColor,
          child:

          DropdownButton<MeasurementType>(
            // isExpanded: true,
              value: _currentMeasurementType,
              iconSize: 24,
              iconEnabledColor: ColorProvider.shared.standardAppButtonTextColor,
              dropdownColor: ColorProvider.shared.standardAppButtonColor,
              elevation: 16,
              style: TextStyle(
                  color: ColorProvider.shared.standardAppButtonTextColor),

              onChanged: (MeasurementType newValue) {
                setState(() {
                  _viewModel.set(newValue);
                });
              },
              items: MeasurementType.values.map<
                  DropdownMenuItem<MeasurementType>>((MeasurementType value) {
                return DropdownMenuItem<MeasurementType>(
                  value: value,
                  child: Text(AppLocalizations.of(context).translate(
                      value.stringName())),
                );
              }).toList()
          ));
  }

    Widget dateRangeSelector(BuildContext context) {
      return
        Container(
          width: 200,
          alignment: Alignment.center,
          color: ColorProvider.shared.standardAppButtonColor,
          child: TextButton(child: Text(
            kDateFormat.format(range.start) + " - " +
                (kDateFormat.format(range.end)), style: TextStyle(
              color: ColorProvider.shared.standardAppButtonTextColor),),
              onPressed: () {
                this._selectDate(context);
              }),

        );
    }

      Widget sensorSelector(BuildContext context) {
        return
          Container(
            width: 200,
            alignment: Alignment.center,
            color: ColorProvider.shared.standardAppButtonColor,
            child:   DropdownButton<Sensor>(
              // isExpanded: true,
                value: _selectedSensor,
                iconSize: 24,
                iconEnabledColor: ColorProvider.shared.standardAppButtonTextColor,
                dropdownColor: ColorProvider.shared.standardAppButtonColor,
                elevation: 16,
                style: TextStyle(
                    color: ColorProvider.shared.standardAppButtonTextColor),

                onChanged: (Sensor newValue) {
                  setState(() {
                    _viewModel.setSensor(newValue);
                  });
                },
                items: _sensors.map<
                    DropdownMenuItem<Sensor>>((Sensor value) {
                  return DropdownMenuItem<Sensor>(
                    value: value,
                    child: Text(value.name),
                  );
                }).toList()),
            );
   }

  Widget chart(BuildContext context) {
    return
      Container(
        width: MediaQuery.of(context).size.width,
        height: 300,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: charts.TimeSeriesChart(seriesList),
      );
  }
}