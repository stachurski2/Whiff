import 'dart:async';
import 'package:Whiff/Services/Data/DataService.dart';
import 'package:Whiff/model/Measurement.dart';
import 'package:Whiff/model/WhiffError.dart';
import 'package:Whiff/model/Sensor.dart';

abstract class MeasurementViewModelContract {

  Stream<Measurement> currentMeasurement();
  Stream<WhiffError> fetchErrorStream();
  String getTermsOfServiceUrl();
  String getPrivacyPolicy();

  void fetchMeasurement(Sensor sensor);
}

class MeasurementViewModel extends MeasurementViewModelContract {

  final DataServicing _dataService = DataService.shared;
  int sensorId;
  void fetchMeasurement(Sensor sensor) {
    _dataService.fetchCurrentMeasurement(sensor);
    this.sensorId = sensor.externalIdentfier;

  }

  Stream<Measurement> currentMeasurement() {
    return _dataService.currentMeasurement().map((serverResponse){
        return serverResponse.responseObject;
    });
  }

  Stream<WhiffError> fetchErrorStream() {
    return _dataService.currentMeasurement().map((serverResponse){
      return serverResponse.error;
    }).where((error){
      if(error.sensorNumber == sensorId) {
        return true;
      }
      return false;
    });
  }

  String getTermsOfServiceUrl() {
    return _dataService.getTermsOfServiceUrl();
  }

  String getPrivacyPolicy() {
    return _dataService.getPrivacyPolicyUrl();
  }

}
