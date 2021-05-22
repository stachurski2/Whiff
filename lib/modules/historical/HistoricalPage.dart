import 'dart:async';
import 'dart:ffi';
import 'package:Whiff/customView/FailurePage.dart';
import 'package:Whiff/customView/LoadingIndicator.dart';
import 'package:Whiff/model/Measurement.dart';
import 'package:Whiff/model/WhiffError.dart';
import 'package:Whiff/modules/state/StatePage.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'package:charts_flutter/src/text_element.dart' as chartText;
import 'package:charts_flutter/src/text_style.dart' as chartStyle;

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
  WhiffError _error;
  WhiffError _sensorError;

  StreamSubscription _mesurementTypeSubscription;
  StreamSubscription _dateRangeSubscription;
  StreamSubscription _sensorListSubscription;
  StreamSubscription _sensorSelectedSubscription;
  StreamSubscription _chartDataSubscription;
  StreamSubscription _chartDataErrorSubscription;
  StreamSubscription _sensorDataErrorSubscription;

  var _didLoadSensors = false;
  var _didLoadChart = false;
  DateTime selectedDate = null;
  double selectedMeasurement = null;

  var symbolRenderer = MySymbolRenderer();
  MeasurementType _currentMeasurementType = MeasurementType.temperature;

  DateTimeRange range =  DateTimeRange(
      end: DateTime.now(),
      start:DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day - 2)

  );


  Future<void> _selectDate(BuildContext context) async {
    DateTimeRange picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      initialDateRange: range,
        builder: (BuildContext context, Widget child) {
      return Theme(
          child: child,
          data: ThemeData.light().copyWith(
            backgroundColor: ColorProvider.shared.standardAppBackgroundColor,
              primaryColor: ColorProvider.shared.standardAppLeftMenuBackgroundColor,
          colorScheme: ColorScheme.light(
              primary: ColorProvider.shared.standardAppButtonColor,
              primaryVariant: ColorProvider.shared.standardAppButtonColor,
              secondary: ColorProvider.shared.standardAppLeftMenuBackgroundColor,
              secondaryVariant: ColorProvider.shared.standardAppLeftMenuBackgroundColor,
              surface: ColorProvider.shared.standardAppBackgroundColor
          ),
          dialogBackgroundColor:ColorProvider.shared.standardAppBackgroundColor,
        )); },

    );
    if(picked != null) {
      _didLoadChart = false;
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
      if(sensorList.length > 0) {
        _didLoadSensors = true;
      }
      _sensors = sensorList;
      _selectedSensor = sensorList.first;
      _didLoadChart = false;
      _viewModel.setSensor(_selectedSensor);
      setState(() {});
    });

    _sensorSelectedSubscription = _viewModel.selectedSensor().listen((sensor) {
      _selectedSensor = sensor;
      setState(() {});
    });

    _chartDataSubscription = _viewModel.chartData().listen((chartData) {
      _error = null;
      _didLoadChart = true;
      seriesList = chartData;
      setState(() {});
    });

    _chartDataErrorSubscription = _viewModel.dataFetchError().listen((error) {
        showFailure(error);
    });

    _sensorDataErrorSubscription = _viewModel.sensorsListFetchError().listen((error) {
      showGeneralFailure(error);
    });
    _viewModel.fetchSensors();
    _viewModel.setTimeRange(range);
  }

  @override
  void deactivate() {
    this.onboardingState.cancel();
    super.deactivate();
  }

  void showFailure(WhiffError error) {
    _error = error;
    setState(() {});
  }

  void showGeneralFailure(WhiffError error) {
    _sensorError = error;
    setState(() {});
  }

  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _didLoadSensors ?  ColorProvider.shared.standardAppLeftMenuBackgroundColor:  ColorProvider.shared.standardAppBackgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
              color: Colors.white)),
      body:
      (_sensorError != null) ? FailurePage(_sensorError, () {
        _sensorError = null;
        _didLoadSensors = false;
        _viewModel.fetchSensors();
        setState(() {});
      },() async {
        _mailToSupport();
      }):
      _didLoadSensors ? Column(children: [
        Container(height: 280,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
            children: [

              SizedBox(height: MediaQuery.of(context).viewPadding.top + 20),
              Text(AppLocalizations.of(context).translate("historical_data_module_title"),
                  style: TextStyle(color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Poppins')),
               SizedBox(height: 20,),

              Row(mainAxisAlignment: MainAxisAlignment.start,
          children: [

            SizedBox(width: 20,),
            Text(AppLocalizations.of(context).translate("historical_top_page_sensor_word"),
              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'Poppins')),
            Spacer(),
            sensorSelector(context),
            SizedBox(width: 20,),
          ],),
        SizedBox(height: 10,),
        Row(mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 20,),
            Text(AppLocalizations.of(context).translate("historical_top_page_date_range_word"),
              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'Poppins')),
            Spacer(),
            dateRangeSelector(context),
            SizedBox(width: 20,),
          ],),
              SizedBox(height: 10,),
              Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20,),
            Text(AppLocalizations.of(context).translate("historical_top_page_type_word"),
                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'Poppins')),
            Spacer(),
            measerementSelector(context),
             SizedBox(width: 20,)
          ],),

          ],
        ),),
        Row( mainAxisAlignment: MainAxisAlignment.center, children: [
          _error == null ? chart(context) : innerFailurePage(context, _error)
        ],),
      ],) : LoadingIndicator(),



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
            color:  ColorProvider.shared.standardAppLeftMenuBackgroundColor,
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
          width: 180,
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
          width: 180,
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
            width: 180,
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
                    _didLoadChart = false;
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
    final size = MediaQuery.of(context).size;

      Map<int, Color> colorCodes = {
        50: Color.fromRGBO(147, 205, 72, .1),
        100: Color.fromRGBO(147, 205, 72, .2),
        200: Color.fromRGBO(147, 205, 72, .3),
        300: Color.fromRGBO(147, 205, 72, .4),
        400: Color.fromRGBO(147, 205, 72, .5),
        500: Color.fromRGBO(147, 205, 72, .6),
        600: Color.fromRGBO(147, 205, 72, .7),
        700: Color.fromRGBO(147, 205, 72, .8),
        800: Color.fromRGBO(147, 205, 72, .9),
        900: Color.fromRGBO(147, 205, 72, 1),
      };

      MaterialColor materialColor = new MaterialColor(0xFF93cd48, colorCodes);

    if(_didLoadChart == true) {
      final currentUnit = AppLocalizations.of(context).translate(_currentMeasurementType.unitName());
      final simpleCurrencyFormatter =  charts.BasicNumericTickFormatterSpec((num value){ return '$value' + currentUnit;});

      List<MeasurementData> data = seriesList.first.data as List<
          MeasurementData>;
      List<DateTime> dataTime = data.map((e) {
        return DateTime(e.time.year, e.time.month, e.time.day);
      }).toList().toSet().toList();
      print(dataTime.length);
      final xScaleCount = (dataTime.length / 7).round() + 1;
      return Expanded(child:
        Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height - 280,
            alignment: Alignment.center,
            color: ColorProvider.shared.standardAppBackgroundColor,
            child: charts.TimeSeriesChart(seriesList,

              animate: false,
              flipVerticalAxis: false,
              selectionModels: [
                charts.SelectionModelConfig(
                    type: charts.SelectionModelType.info,
                    changedListener: (charts.SelectionModel model) {
                      if(model.hasDatumSelection) {

                        symbolRenderer.set(model.selectedSeries[0].domainFn(model.selectedDatum[0].index), model.selectedSeries[0].measureFn(model.selectedDatum[0].index), AppLocalizations.of(context).translate(_currentMeasurementType.unitName()), MediaQuery.of(context).size.width);
                      }
                    }

                )
              ],
              behaviors: [
                charts.SelectNearest(
                    eventTrigger: charts.SelectionTrigger.tapAndDrag
                ),
                charts.LinePointHighlighter(
                  symbolRenderer: symbolRenderer,
                ),
              ],

              primaryMeasureAxis: new charts.NumericAxisSpec(
              tickFormatterSpec: simpleCurrencyFormatter,
                  renderSpec: new charts.GridlineRendererSpec(
                    lineStyle: new charts.LineStyleSpec(color: charts.Color.fromHex(code: "#0D5509")),
                    // Display the measure axis labels below the gridline.
                    //
                    // 'Before' & 'after' follow the axis value direction.
                    // Vertical axes draw 'before' below & 'after' above the tick.
                    // Horizontal axes draw 'before' left & 'after' right the tick.
                    labelAnchor: charts.TickLabelAnchor.centered,

                    // Left justify the text in the axis.
                    //
                    // Note: outside means that the secondary measure axis would right
                    // justify.
                    labelJustification: charts.TickLabelJustification.outside,
                  )),
              domainAxis: charts.DateTimeAxisSpec(
                showAxisLine: true,
                tickProviderSpec: charts.DayTickProviderSpec(
                    increments: [xScaleCount]),
                tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                    day: new charts.TimeFormatterSpec(
                        format: 'dd MMM',
                        transitionFormat: 'dd MMM',
                        noonFormat: 'dd MMM')),

              ),
              // behaviors: [ charts.RangeAnnotation(data.map((e){charts.LineAnnotationSegment(e.time, charts.RangeAnnotationAxisType.domain, middleLabel: '\e.sales');}).toList())],
            )
        ));
    } else {
      return  Expanded(child:
      Container(
          height: MediaQuery
              .of(context)
              .size
              .height - 280,
          color: ColorProvider.shared.standardAppBackgroundColor,
          child:LoadingIndicator()));
    }
  }

  Widget innerFailurePage(BuildContext context, WhiffError error) {
    final size = MediaQuery.of(context).size;

      final currentUnit = AppLocalizations.of(context).translate(
          _currentMeasurementType.unitName());
      final simpleCurrencyFormatter = charts.BasicNumericTickFormatterSpec((
          num value) {
        return '$value' + currentUnit;
      });
      return Expanded(child:
      Container(
          padding: EdgeInsets.all(20),
          width: MediaQuery
              .of(context)
              .size
              .width - 100,
          height: MediaQuery
              .of(context)
              .size
              .height - 280,
          alignment: Alignment.center,
          color: ColorProvider.shared.standardAppBackgroundColor,
          child:
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
    FailurePage(error, (){
      _error = null;
      _didLoadChart = false;
      _viewModel.setSensor(_selectedSensor);
      setState(() {});
    }, () async {
    await this._mailToSupport();
    })
      ],)));
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

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}



class MySymbolRenderer extends charts.CustomSymbolRenderer {

  final DateFormat kDateFormat = DateFormat("dd MMM yy hh:mm");

  DateTime _selectedDate = DateTime.now();
  double _selectedMeasurement = 0;
  String _unit = "";
  double _screenWidth = 0;


  void set(DateTime date, double measurement, String unit, double screenWidth ) {
        this._selectedMeasurement = measurement;
        this._selectedDate = date;
        this._unit = unit;
        this._screenWidth = screenWidth;

  }

  Rect _getRect(Rectangle<num> rectangle) {
    return new Rect.fromLTWH(
        rectangle.left.toDouble(),
        rectangle.top.toDouble(),
        rectangle.width.toDouble(),
        rectangle.height.toDouble());
  }

  @override
  Widget build(BuildContext context, {Color color, Size size, bool enabled}) {
    return new Container(height: 100, width: 100, color: ColorProvider.shared.standardAppBackgroundColor);
  }

  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern,
        charts.Color fillColor,
        charts.FillPatternType fillPattern,
        charts.Color strokeColor,
        double strokeWidthPx}) {
    print(this._screenWidth);
    var textStyle = chartStyle.TextStyle();

    textStyle.fontSize = 14;
    textStyle.fontFamily = 'Poppins';
    textStyle.color = charts.Color.white;

    var paint1 = Paint()
      ..color = Color(0xff638965)
      ..style = PaintingStyle.fill;
    double left = bounds.left + 150 > _screenWidth ? bounds.left - 110 : bounds.left;
    canvas.drawRect(Rectangle(left, bounds.top, 110, 45), fill: charts.Color.fromHex(code: "#00916E"));
    canvas.drawText(chartText.TextElement(kDateFormat.format(_selectedDate), style: textStyle) , (left + 5).toInt(), (bounds.top + 5).toInt());
    canvas.drawText(chartText.TextElement(_selectedMeasurement.toString()+" " + _unit, style: textStyle) , (left + 5).toInt(), (bounds.top + 5).toInt() + 20);
  }

}

