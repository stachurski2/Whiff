import 'dart:async';
import 'package:Whiff/Services/Data/DataService.dart';
import 'package:Whiff/model/Measurement.dart';
import 'package:Whiff/model/WhiffError.dart';

abstract class MeasurementViewModelContract {

  Stream<Measurement> currentMeasurement();
  Stream<WhiffError> fetchErrorStream();

  void fetchMeasurement(int sensorId);
}

class MeasurementViewModel extends MeasurementViewModelContract {

  final DataServicing _dataService = DataService.shared;

  void fetchMeasurement(int sensorId) {
    _dataService.fetchCurrentMeasurement(sensorId);
  }

  Stream<Measurement> currentMeasurement() {
    return _dataService.currentMeasurement().map((serverResponse){
        return serverResponse.responseObject;
    });
  }

  Stream<WhiffError> fetchErrorStream() {
    return _dataService.currentMeasurement().map((serverResponse){
      return serverResponse.error;
    });
  }

}
