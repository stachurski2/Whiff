import 'dart:async';
import 'package:Whiff/Services/Data/DataService.dart';
import 'package:Whiff/model/Measurement.dart';
import 'package:Whiff/model/WhiffError.dart';
import 'package:Whiff/model/Sensor.dart';

abstract class MeasurementViewModelContract {

  Stream<Measurement> currentMeasurement();
  Stream<WhiffError> fetchErrorStream();

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
      print(error.sensorNumber);
      print(sensorId);

      if(error.sensorNumber == sensorId) {
        print("true");

        return true;
      }
      print("false");

      return false;
    });
  }

}
