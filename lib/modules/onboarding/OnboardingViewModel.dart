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
abstract class OnboardingViewModelContract {
  Stream<AutheticationState> currentAuthState();

  Stream<List<Sensor>> sensorsList();

  Stream<List<Measurement>> currentMeasurements();

  Stream<WhiffError> sensorsListFetchError();

  Stream<AirState> currentState();

  String signedInEmail();

  void signOut();

  void fetchSensors();

  void fetchState();

  void fetchMeasurement(Sensor sensor);
}

class OnboardingViewModel extends OnboardingViewModelContract {

  final AutheticatingServicing _authenticationService = AutheticationService.shared;
  final DataServicing _dataService = DataService.shared;

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

  void fetchState() {
    _dataService.fetchState();
  }

  void fetchMeasurement(Sensor sensor) {
    _dataService.fetchCurrentMeasurement(sensor);
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

  Stream<AirState> currentState() {
    return _dataService.currentState().map((serverResponse){
      return serverResponse.responseObject;
    }).where((responseObject){
      return responseObject != null;
    });
  }

  Stream<List<Measurement>> currentMeasurements() {
    return _dataService.currentMeasurement().transform(ScanStreamTransformer((List<Measurement> array, ServerResponse response, int index){

      if(response.responseObject != null) {
        Measurement newMeasurement = response.responseObject;
        List<Measurement> newMeasurements = array.where((measurement) => measurement.deviceNumber != newMeasurement.deviceNumber).toList();
        newMeasurements.add(newMeasurement);
        return newMeasurements;
      } else {
        return array;
      }

    }, []));
  }
}