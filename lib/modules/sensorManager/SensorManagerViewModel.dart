import 'dart:async';
import 'package:Whiff/Services/Networking/ServerResponse.dart';
import 'package:rxdart/rxdart.dart';

import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/Services/Data/DataService.dart';
import 'package:Whiff/model/Measurement.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:Whiff/model/WhiffError.dart';
import 'package:Whiff/model/AirState.dart';

abstract class SensorManagerViewModelContract {

  Stream<List<Sensor>> sensorsList();

  Stream<WhiffError> sensorsListFetchError();

  Stream<WhiffError> sensorAddError();

  void fetchSensors();

  void setSensorKey(String key);

  void setSensorNumber(String number);

  void requestDeleteSensor(String number);

  void requestAddSensor();
}

class SensorManagerViewModel extends SensorManagerViewModelContract {

  String sensorKey = "";
  String sensorNumber = "";

  final AutheticatingServicing _authenticationService = AutheticationService.shared;
  final DataServicing _dataService = DataService.shared;

  void fetchSensors() {
    _dataService.fetchSensors();
  }

  Stream<List<Sensor>> sensorsList() {
    return _dataService.fetchedSensors().map((serverResponse){
      return serverResponse.responseObject;
    });
  }
  Stream<WhiffError> sensorsListFetchError() {
    return _dataService.fetchedSensors().map((serverResponse){
      return serverResponse.error;
    });
  }

  void setSensorKey(String key){
      sensorKey = key;
  }

  void setSensorNumber(String number) {
       sensorNumber = number;
  }

  void requestDeleteSensor(String number) {
      _dataService.requestDelete(number);
  }


  void requestAddSensor() {
    _dataService.requestAdd(sensorKey, sensorNumber);
  }

  Stream<WhiffError> sensorAddError() {
    return _dataService.addSensorError();
  }



}