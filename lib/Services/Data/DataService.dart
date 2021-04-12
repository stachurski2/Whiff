import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Networking/Networking.dart';
import 'package:Whiff/Services/Networking/ServerResponse.dart';
import 'package:Whiff/model/Measurement.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:Whiff/model/WhiffError.dart';
import 'package:rxdart/rxdart.dart';

abstract class DataServicing {
   void fetchSensors() async { }
   void fetchState() async { }
   void fetchCurrentMeasurement(int sensorId) async { }
   void fetchHistoricalData(DateTime startDate, DateTime endDate, int sensorId) async { }
   Stream<ServerResponse<List<Sensor>>> fetchedSensors();
   Stream<ServerResponse<Measurement>> currentMeasurement();
   Stream<ServerResponse<List<Measurement>>> historicalMeasurements();

}

class DataService extends DataServicing  {

  DataService._internal();

  static final DataService shared = DataService._internal();
  factory DataService() {
    return shared;
  }

  final _fetchedSensorsSubject = PublishSubject<ServerResponse<List<Sensor>>>();

  final _currentMeasurementSubject = PublishSubject<ServerResponse<Measurement>>();

  final _historicalMeasurementsSubject = PublishSubject<ServerResponse<List<Measurement>>>();

  Stream<ServerResponse<List<Sensor>>> fetchedSensors() {
    return _fetchedSensorsSubject.stream;
  }

  Stream<ServerResponse<Measurement>> currentMeasurement() {
    return _currentMeasurementSubject.stream;
  }

  Stream<ServerResponse<List<Measurement>>> historicalMeasurements() {
    return _historicalMeasurementsSubject.stream;
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

  void fetchHistoricalData(DateTime startDate, DateTime endDate, int sensorId) async {
    String startDateString = startDate.year.toString() + (startDate.month > 9 ? "-":"-0") + startDate.month.toString() + (startDate.day > 9 ? "-":"-0") +startDate.day.toString() + " 0";
    String endDateString = endDate.year.toString() + (endDate.month > 9 ? "-":"-0") + endDate.month.toString() + (endDate.day > 9 ? "-":"-0") + endDate.day.toString() + " 23";

    print(startDateString);
    print(endDateString);
    var response = await networkService.makeRequest(RequestMethod.get, "/sensorData", {"sensorId": sensorId.toString(), "startDate": startDateString, "endDate":endDateString}, _autheticatingService.authorizationHeader());
    if(response.error != null) {
      _historicalMeasurementsSubject.add(ServerResponse(null, WhiffError.responseDecodeProblem()));
    } else if (response.responseObject["data"] != null) {
      Map<String, dynamic> data = response.responseObject["data"];
      List<dynamic> measures = data["measures"];

      final measuresList = measures.map((dictionary){
        return Measurement(double.parse(dictionary["PM1"]),
                           double.parse(dictionary["PM10"]),
                              double.parse(dictionary["PM25"]),
                             double.parse(dictionary["WILGOTNOSC"]),
                            double.parse(dictionary["FORMALDEHYD"]),
                             double.parse(dictionary["CO2"]),
                             double.parse(dictionary["TEMPERATURA"]),
                             DateTime.parse(dictionary["DATA_GODZINA"]));
      });

        int paramater = (measuresList.length/300).round() + 1;

        List<Measurement> list = [];
        for (int i = 0; i < measuresList.length; i++) {
          if (i % paramater == 0) {
            list.add(measuresList.elementAt(i));
          }
        }
        print(paramater);
        print(measuresList);
        print(list.length);
      _historicalMeasurementsSubject.add(ServerResponse(list, null));
    } else {
      _historicalMeasurementsSubject.add(ServerResponse(null, WhiffError.responseDecodeProblem()));
    }

    void fetchState() async {
      var response = await networkService.makeRequest(RequestMethod.get, "/currentStateData", null ,_autheticatingService.authorizationHeader());
      print(response);
    }
  }
}
