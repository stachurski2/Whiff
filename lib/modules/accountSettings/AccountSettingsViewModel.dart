import 'dart:async';
import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/Services/Data/DataService.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:Whiff/model/WhiffError.dart';

abstract class AccountSettingsViewModelContract {
  Stream<AutheticationState> currentAuthState();
  Stream<List<Sensor>> sensorsList();
  Stream<WhiffError> sensorsListFetchError();
  String signedInEmail();
  void signOut();
  void fetchSensors();
}

class AccountSettingsViewModel extends AccountSettingsViewModelContract {

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
}