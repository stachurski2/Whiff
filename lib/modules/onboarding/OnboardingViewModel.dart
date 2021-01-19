import 'dart:async';
import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/Services/Data/DataService.dart';
import 'package:Whiff/model/Measurement.dart';
import 'package:Whiff/model/Sensor.dart';

abstract class OnboardingViewModelContract {
  Stream<AutheticationState> currentAuthState();
  Stream<List<Sensor>> sensorsList();

  String signedInEmail();
  void signOut();
  void fetchSensors();
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

  Stream<List<Sensor>> sensorsList() {
    return _dataService.fetchedSensors().map((serverResponse){
        return serverResponse.responseObject;
    });
  }
}