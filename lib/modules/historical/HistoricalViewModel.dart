import 'dart:async';
import 'package:Whiff/model/MeasurementType.dart';

import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/Services/Data/DataService.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:Whiff/model/WhiffError.dart';
import 'package:rxdart/rxdart.dart';

abstract class HistoricalViewModelContract {
  Stream<AutheticationState> currentAuthState();
  Stream<MeasurementType> currentMeasurementType();
  Stream<WhiffError> sensorsListFetchError();
  String signedInEmail();
  void signOut();
  void set(MeasurementType type);
}

class HistoricalViewModel extends HistoricalViewModelContract {

  final AutheticatingServicing _authenticationService = AutheticationService.shared;
  final DataServicing _dataService = DataService.shared;
  
  final _currentMeasurumentTypeSubject = BehaviorSubject<MeasurementType>();

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

  Stream<MeasurementType> currentMeasurementType(){
    return _currentMeasurumentTypeSubject.stream.startWith(MeasurementType.temperature);
  }
  Stream<WhiffError> sensorsListFetchError() {
    return _dataService.fetchedSensors().map((serverResponse){
      return serverResponse.error;
    });
  }
}