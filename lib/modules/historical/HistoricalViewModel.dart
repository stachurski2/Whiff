import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Whiff/model/MeasurementType.dart';
import 'package:Whiff/model/Measurement.dart';

import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/Services/Data/DataService.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:Whiff/model/WhiffError.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:Whiff/helpers/color_provider.dart';


abstract class HistoricalViewModelContract {
  Stream<AutheticationState> currentAuthState();
  Stream<MeasurementType> currentMeasurementType();
  Stream<DateTimeRange> currentDateRange();
  Stream<List<Sensor>> sensorsList();
  Stream<Sensor> selectedSensor();
  Stream<WhiffError> sensorsListFetchError();
  Stream<List<charts.Series<dynamic, DateTime>>> chartData();

  String signedInEmail();
  void signOut();
  void set(MeasurementType type);
  void setTimeRange(DateTimeRange dateRange);
  void setSensor(Sensor sensor);
  void fetchSensors();

}

class HistoricalViewModel extends HistoricalViewModelContract {

  final AutheticatingServicing _authenticationService = AutheticationService.shared;
  final DataServicing _dataService = DataService.shared;

  StreamSubscription _dataFetchSubscription;


  final _currentMeasurumentTypeSubject = BehaviorSubject<MeasurementType>();
  final _selectedDateRangeSubject = BehaviorSubject<DateTimeRange>();
  final _selectedSensorSubject = BehaviorSubject<Sensor>();


  HistoricalViewModel() {
    _dataFetchSubscription =  Rx.combineLatest2(_selectedDateRangeSubject, _selectedSensorSubject, (dateRange, selectedSensor) => {
      Tuple2<DateTimeRange, Sensor>(dateRange, selectedSensor)
    }).listen((data) {


      _dataService.fetchHistoricalData(data.last.item1.start, data.last.item1.end, data.last.item2);

    });
  }

  void signOut() {
    _authenticationService.signOut();
  }

  String signedInEmail() {
    return _authenticationService.signedInEmail();
  }

  Stream<AutheticationState> currentAuthState() {
    return _authenticationService.currentAuthState();
  }

  void fetchSensors() {
    _dataService.fetchSensors();
  }

  void set(MeasurementType type) {
    _currentMeasurumentTypeSubject.add(type);
  }

  void setTimeRange(DateTimeRange dateRange) {
    _selectedDateRangeSubject.add(dateRange);
  }

  void setSensor(Sensor sensor) {
    _selectedSensorSubject.add(sensor);
  }


  Stream<MeasurementType> currentMeasurementType(){
    return _currentMeasurumentTypeSubject.stream.startWith(MeasurementType.temperature);
  }

  Stream<DateTimeRange> currentDateRange() {
    return _selectedDateRangeSubject.stream;

  }
  Stream<WhiffError> sensorsListFetchError() {
    return _dataService.fetchedSensors().map((serverResponse){
      return serverResponse.error;
    });
  }
  Stream<List<Sensor>> sensorsList() {
    return _dataService.fetchedSensors().map((serverResponse){
      return serverResponse.responseObject;
    });
  }

  Stream<Sensor> selectedSensor() {
    return _selectedSensorSubject.stream;
  }

  Stream<List<charts.Series<dynamic, DateTime>>> chartData() {
    final dataStream =  _dataService.historicalMeasurements().map((serverResponse){
      return serverResponse.responseObject;
    });

   return Rx.combineLatest2(dataStream, _currentMeasurumentTypeSubject.stream.startWith(MeasurementType.temperature), (fetchedMeasurements, measurementTyp) {
     final measurements = fetchedMeasurements as List<Measurement>;
      final measurementType = measurementTyp as MeasurementType;
      switch(measurementType){
        case MeasurementType.temperature:
          final data = measurements.map((measurement){ return MeasurementData(measurement.date, measurement.temperature);}).toList();
          return [charts.Series<MeasurementData, DateTime>(
                id: measurementType.stringName(),
                 colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                domainFn: (MeasurementData sales, _) => sales.time,
                 measureFn: (MeasurementData sales, _) => sales.sales,
                data: data
          )];
        case MeasurementType.formaldehyde:
          final data = measurements.map((measurement){ return MeasurementData(measurement.date, measurement.formaldehyde);}).toList();
          return [charts.Series<MeasurementData, DateTime>(
              id: measurementType.stringName(),
              colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
              domainFn: (MeasurementData sales, _) => sales.time,
              measureFn: (MeasurementData sales, _) => sales.sales,
              data: data
          )];
        case MeasurementType.co2level:
          final data = measurements.map((measurement){ return MeasurementData(measurement.date, measurement.co2level);}).toList();
          return [charts.Series<MeasurementData, DateTime>(
              id: measurementType.stringName(),
              colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
              domainFn: (MeasurementData sales, _) => sales.time,
              measureFn: (MeasurementData sales, _) => sales.sales,
              data: data
          )];
          case MeasurementType.pm1level:
            final data = measurements.map((measurement){ return MeasurementData(measurement.date, measurement.pm1Level);}).toList();
            return [charts.Series<MeasurementData, DateTime>(
                id: measurementType.stringName(),
                colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                domainFn: (MeasurementData sales, _) => sales.time,
                measureFn: (MeasurementData sales, _) => sales.sales,
                data: data
            )];
            case MeasurementType.pm25level:
              final data = measurements.map((measurement){ return MeasurementData(measurement.date, measurement.pm25level);}).toList();
              return [charts.Series<MeasurementData, DateTime>(
                  id: measurementType.stringName(),
                  colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                  domainFn: (MeasurementData sales, _) => sales.time,
                  measureFn: (MeasurementData sales, _) => sales.sales,
                  data: data
              )];
              case MeasurementType.pm10level:
                final data = measurements.map((measurement){ return MeasurementData(measurement.date, measurement.pm10Level);}).toList();
                return [charts.Series<MeasurementData, DateTime>(
                    id: measurementType.stringName(),
                    colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                    domainFn: (MeasurementData sales, _) => sales.time,
                    measureFn: (MeasurementData sales, _) => sales.sales,
                    data: data
                )];
                case MeasurementType.humidity:
                  final data = measurements.map((measurement){ return MeasurementData(measurement.date, measurement.humidity);}).toList();
                  return [charts.Series<MeasurementData, DateTime>(
                      id: measurementType.stringName(),
                      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                      domainFn: (MeasurementData sales, _) => sales.time,
                      measureFn: (MeasurementData sales, _) => sales.sales,
                      data: data
                  )];
                  return [];
      }
      return [];
    });

  }
}


class MeasurementData {
  final DateTime time;
  final double sales;

  MeasurementData(this.time, this.sales);
}