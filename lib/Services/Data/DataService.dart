import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Networking/Networking.dart';
import 'package:Whiff/Services/Networking/ServerResponse.dart';
import 'package:Whiff/model/Measurement.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:Whiff/model/WhiffError.dart';
import 'package:rxdart/rxdart.dart';

abstract class DataServicing {
   void fetchSensors() async { }
   void fetchCurrentMeasurement(int sensorId) async { }
   Stream<ServerResponse<List<Sensor>>> fetchedSensors();
   Stream<ServerResponse<Measurement>> currentMeasurement();

}

class DataService extends DataServicing  {

  DataService._internal();

  static final DataService shared = DataService._internal();
  factory DataService() {
    return shared;
  }

  final _fetchedSensorsSubject = PublishSubject<ServerResponse<List<Sensor>>>();

  final _currentMeasurementSubject = PublishSubject<ServerResponse<Measurement>>();

  Stream<ServerResponse<List<Sensor>>> fetchedSensors() {
    return _fetchedSensorsSubject.stream;
  }

  Stream<ServerResponse<Measurement>> currentMeasurement() {
    return _currentMeasurementSubject.stream;
  }

  NetworkingServicing networkService = NetworkService.shared;

  NetworkingServicing _networkService = NetworkService.shared;
  AutheticatingServicing _autheticatingService = AutheticationService.shared;

  void fetchSensors() async {
    var response = await networkService.makeRequest(RequestMethod.get, "/sensorList", { }, _autheticatingService.authorizationHeader());
    if (response.error != null) {
      print("error");
      _fetchedSensorsSubject.add(ServerResponse(null, response.error));
    } else {
      if (response.responseObject != null) {
        if (response.responseObject["sensors"] != null) {
          var sensorList = List<Sensor>();
          final sensorsData = response.responseObject["sensors"];
          if (sensorsData != null) {
            for (var i = 0; i < sensorsData.length; i++) {
              sensorList.add(Sensor(sensorsData[i]["name"],
                  sensorsData[i]["externalIdentifier"],
                  sensorsData[i]["locationName"],
                  sensorsData[i]["locationLat"],
                  sensorsData[i]["locationLon"],
                  sensorsData[i]["locationTimeZone"]));
            }
            _fetchedSensorsSubject.add(ServerResponse(sensorList, null));
          } else {
            _fetchedSensorsSubject.add(
                ServerResponse(null, WhiffError.responseDecodeProblem()));
          }
        } else {
          _fetchedSensorsSubject.add(
              ServerResponse(null, WhiffError.responseDecodeProblem()));
        }
      } else {
        _fetchedSensorsSubject.add(
            ServerResponse(null, WhiffError.responseDecodeProblem()));
      }
    }
  }

  void fetchCurrentMeasurement(int sensorId) async {
    var response = await networkService.makeRequest(RequestMethod.get, "/lastPieceOfDataFromSensor", {"sensorId": sensorId.toString()}, _autheticatingService.authorizationHeader());
    if(response.error != null) {
      _currentMeasurementSubject.add(ServerResponse(null, response.error));
    } else  if(response.responseObject["data"] != null) {
      var data = response.responseObject["data"];
      var measurement = Measurement(double.parse(data["PM1"]),
                                    double.parse(data["PM10"]),
                                    double.parse(data["PM25"]),
                                    double.parse(data["WILGOTNOSC"]),
                                    double.parse(data["FORMALDEHYD"]),
                                    double.parse(data["CO2"]),
                                    double.parse(data["TEMPERATURA"]),
                                    DateTime.parse(data["CZAS"]));
      _currentMeasurementSubject.add(ServerResponse(measurement, null));
    } else {
      _currentMeasurementSubject.add(ServerResponse(null, WhiffError.responseDecodeProblem()));
    }
  }
}
