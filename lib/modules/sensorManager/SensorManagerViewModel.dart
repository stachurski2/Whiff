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

  void fetchSensors();

  void setSensorPreSharedKey(String key);

  void requestAddSensor();
}

class SensorManagerViewModel extends SensorManagerViewModelContract {

  String preSharedKey = "";
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

  void setSensorPreSharedKey(String key) {
    preSharedKey = key;
  }

  void requestAddSensor() {
    _dataService.requestAdd(preSharedKey);
  }


}