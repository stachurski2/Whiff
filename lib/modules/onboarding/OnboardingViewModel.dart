import 'dart:async';
import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/Services/Data/DataService.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:Whiff/model/WhiffError.dart';
import 'package:Whiff/model/AirState.dart';
abstract class OnboardingViewModelContract {
  Stream<AutheticationState> currentAuthState();

  Stream<List<Sensor>> sensorsList();

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
    _dataService.fetchCurrentMeasurement(sensor.externalIdentfier);
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
}