import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Networking/Networking.dart';
import 'package:Whiff/Services/Networking/ServerResponse.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:rxdart/rxdart.dart';

abstract class DataServicing {
   void fetchSensors() async { }
   Stream<ServerResponse<List<Sensor>>> fetchedSensors();
}

class DataService extends DataServicing  {

  DataService._internal();

  static final DataService shared = DataService._internal();
  factory DataService() {
    return shared;
  }

  final _fetchedSensorsSubject = PublishSubject<ServerResponse<List<Sensor>>>();

  Stream<ServerResponse<List<Sensor>>> fetchedSensors() {
    return _fetchedSensorsSubject.stream;
  }

  NetworkingServicing networkService = NetworkService.shared;

  NetworkingServicing _networkService = NetworkService.shared;
  AutheticatingServicing _autheticatingService = AutheticationService.shared;

  void fetchSensors() async {
    var response = await networkService.makeRequest(RequestMethod.get, "/sensorList", { }, _autheticatingService.authorizationHeader());
    if(response.responseObject["sensors"] != null) {
         var sensorList = List<Sensor>();
        final sensorsData = response.responseObject["sensors"];
         if(sensorsData != null) {
           for (var i = 0; i < sensorsData.length; i++) {
             print(sensorsData[i]);
              sensorList.add(Sensor(sensorsData[i]["name"],
                  sensorsData[i]["externalIdentifier"],
                  sensorsData[i]["locationName"],
                   sensorsData[i]["locationLat"],
                   sensorsData[i]["locationLon"],
                    sensorsData[i]["locationTimeZone"]));

           }
           _fetchedSensorsSubject.add(ServerResponse(sensorList, null, null));

         } else {

         }

    } else if(response.errorMessage != null) {

    }
  }
}
