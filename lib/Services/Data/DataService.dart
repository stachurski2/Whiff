import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Networking/Networking.dart';
import 'package:Whiff/Services/Networking/ServerResponse.dart';
import 'package:Whiff/model/AirState.dart';
import 'package:Whiff/model/Measurement.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:Whiff/model/WhiffError.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Whiff/model/AirState.dart';

abstract class DataServicing {
   void fetchSensors() async { }
   void fetchState() async { }
   void requestDemo() async { }
   void requestAdd(String sensorKey) async { }

   void fetchCurrentMeasurement(Sensor sensor) async { }
   void fetchHistoricalData(DateTime startDate, DateTime endDate, Sensor sensor) async { }
   Stream<ServerResponse<List<Sensor>>> fetchedSensors();
   Stream<ServerResponse<Measurement>> currentMeasurement();
   Stream<ServerResponse<List<Measurement>>> historicalMeasurements();
   Stream<ServerResponse<AirState>> currentState();
   Stream<ServerResponse<bool>> demoState();

   String getTermsOfServiceUrl();
   String getPrivacyPolicyUrl();
}

class DataService extends DataServicing  {

  DataService._internal();

  static final DataService shared = DataService._internal();
  factory DataService() {
    return shared;
  }

  final _fetchedSensorsSubject = ReplaySubject<ServerResponse<List<Sensor>>>(maxSize:1);

  final _currentMeasurementSubject = ReplaySubject<ServerResponse<Measurement>>(maxSize: 10);

  final _historicalMeasurementsSubject = PublishSubject<ServerResponse<List<Measurement>>>();

  final _curentStateSubject = PublishSubject<ServerResponse<AirState>>();

  final _demoSubject = PublishSubject<ServerResponse<bool>>();

  Stream<ServerResponse<List<Sensor>>> fetchedSensors() {
    return _fetchedSensorsSubject.stream;
  }

  Stream<ServerResponse<Measurement>> currentMeasurement() {
    return _currentMeasurementSubject.stream;
  }

  Stream<ServerResponse<List<Measurement>>> historicalMeasurements() {
    return _historicalMeasurementsSubject.stream;
  }

  Stream<ServerResponse<AirState>> currentState() {
    return _curentStateSubject.stream;
  }


  NetworkingServicing networkService = NetworkService.shared;

  NetworkingServicing _networkService = NetworkService.shared;
  AutheticatingServicing _autheticatingService = AutheticationService.shared;

  void fetchSensors() async {
    var response = await networkService.makeRequest(RequestMethod.get, "/sensorList", { }, _autheticatingService.authorizationHeader());
    if (response.error != null) {
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
                  sensorsData[i]["locationTimeZone"],
                  sensorsData[i]["isInsideBuilding"]));
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

  void fetchCurrentMeasurement(Sensor sensor) async {
    var response = await networkService.makeRequest(RequestMethod.get, "/lastPieceOfDataFromSensor", {"sensorId": sensor.externalIdentfier.toString()}, _autheticatingService.authorizationHeader());
    if(response.error != null) {
      _currentMeasurementSubject.add(ServerResponse(null, WhiffError(response.error.errorCode, response.error.errorMessage, sensorNumber: sensor.externalIdentfier )));
    } else if(response.responseObject["data"] != null) {
      var data = response.responseObject["data"];
      var measurement = Measurement(int.parse(data["ID_URZADZENIA"]),
                                    double.parse(data["PM1"]),
                                    double.parse(data["PM10"]),
                                    double.parse(data["PM25"]),
                                    double.parse(data["WILGOTNOSC"]),
                                    double.parse(data["FORMALDEHYD"]),
                                    double.parse(data["CO2"]),
                                    double.parse(data["TEMPERATURA"]),
                                    DateTime.parse(data["CZAS"]),
                                    sensor.isInsideBuilding);
     _currentMeasurementSubject.add(ServerResponse(measurement, null));
    } else {
      _currentMeasurementSubject.add(ServerResponse(null, WhiffError(response.error.errorCode, response.error.errorMessage, sensorNumber: sensor.externalIdentfier)));
    }
  }

  void fetchHistoricalData(DateTime startDate, DateTime endDate, Sensor sensor) async {
    String startDateString = startDate.year.toString() + (startDate.month > 9 ? "-":"-0") + startDate.month.toString() + (startDate.day > 9 ? "-":"-0") +startDate.day.toString() + " 0";
    String endDateString = endDate.year.toString() + (endDate.month > 9 ? "-":"-0") + endDate.month.toString() + (endDate.day > 9 ? "-":"-0") + endDate.day.toString() + " 23";

    var response = await networkService.makeRequest(RequestMethod.get, "/sensorData", {"sensorId": sensor.externalIdentfier.toString(), "startDate": startDateString, "endDate":endDateString}, _autheticatingService.authorizationHeader());
    if(response.error != null) {
      _historicalMeasurementsSubject.add(ServerResponse(null, response.error));
    } else if (response.responseObject["data"] != null) {
      Map<String, dynamic> data = response.responseObject["data"];
      List<dynamic> measures = data["measures"];

      final measuresList = measures.map((dictionary){
                var measurement = Measurement(int.parse(dictionary["ID_URZADZENIA"]),
                          double.parse(dictionary["PM1"]),
                           double.parse(dictionary["PM10"]),
                              double.parse(dictionary["PM25"]),
                             double.parse(dictionary["WILGOTNOSC"]),
                            double.parse(dictionary["FORMALDEHYD"]),
                             double.parse(dictionary["CO2"]),
                             double.parse(dictionary["TEMPERATURA"]),
                             DateTime.parse(dictionary["DATA_GODZINA"]),
                              sensor.isInsideBuilding);
        return measurement;
      });

        int paramater = (measuresList.length/300).round() + 1;

        List<Measurement> list = [];

        for (int i = 0; i < measuresList.length; i++) {
          if (i % paramater == 0) {
            list.add(measuresList.elementAt(i));
          }
        }
      _historicalMeasurementsSubject.add(ServerResponse(list, null));
    } else {
      _historicalMeasurementsSubject.add(ServerResponse(null, WhiffError.responseDecodeProblem()));
    }
  }


  void fetchState() async {
    var response = await networkService.makeRequest(RequestMethod.get, "/currentStateData", {} ,_autheticatingService.authorizationHeader());
     if(response.error != null) {
       _curentStateSubject.add(ServerResponse(AirState.unknown, null));
     } else if(response.responseObject["data"] != null) {
       var data = response.responseObject["data"];
       print(response.responseObject);
       var measurement = Measurement(
           int.parse(data["ID_URZADZENIA"]),
           double.parse(data["PM1"]),
           double.parse(data["PM10"]),
           double.parse(data["PM25"]),
           double.parse(data["WILGOTNOSC"]),
           double.parse(data["FORMALDEHYD"]),
           double.parse(data["CO2"]),
           double.parse(data["TEMPERATURA"]),
           DateTime.parse(data["CZAS"]),
           false);
           _curentStateSubject.add(ServerResponse(measurement.getState(), null));
     } else {
       _curentStateSubject.add(ServerResponse(AirState.unknown, null));
     }
  }

  void requestDemo() async {
    var response = await networkService.makeRequest(RequestMethod.post, "/requestDemo", {} ,_autheticatingService.authorizationHeader());
    if(response.error != null) {
      _demoSubject.add(ServerResponse(null, response.error));
    } else {
      _demoSubject.add(ServerResponse(true, null));
    }
  }

  void requestAdd(String sensorKey) async {
    var response = await networkService.makeRequest(RequestMethod.post, "/requestAddSensor", {"sensorId": sensorKey} ,_autheticatingService.authorizationHeader());
    if(response.error == null) {
      fetchSensors();
    }
  }


  Stream<ServerResponse<bool>> demoState()  {
    return _demoSubject.stream;
  }

  String getTermsOfServiceUrl() {
    return _networkService.getTermsOfServiceUrl();
  }

  String getPrivacyPolicyUrl() {
    return _networkService.getPrivacyPolicyUrl();
  }
}
