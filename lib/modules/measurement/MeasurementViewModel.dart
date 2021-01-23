import 'dart:async';
import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/Services/Data/DataService.dart';
import 'package:Whiff/model/Measurement.dart';
import 'package:Whiff/model/Sensor.dart';

abstract class MeasurementViewModelContract {

  Stream<Measurement> currentMeasurement();
  void fetchMeasurement();
}

class MeasurementViewModel extends MeasurementViewModelContract {

  void fetchMeasurement() {

  }

  Stream<Measurement> currentMeasurement() {

  }
}