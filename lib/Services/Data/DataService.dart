import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Networking/Networking.dart';

abstract class DataServicing {
   void fetchSensors() async { }
}

class DataService extends DataServicing  {

  DataService._internal();

  static final DataService shared = DataService._internal();
  factory DataService() {
    return shared;
  }

  NetworkingServicing networkService = NetworkService.shared;

  NetworkingServicing _networkService = NetworkService.shared;
  AutheticatingServicing _autheticatingService = AutheticationService.shared;

  void fetchSensors() async {
    var response = await networkService.makeRequest(RequestMethod.get, "/sensorList", { }, _autheticatingService.authorizationHeader());
    if(response.responseObject != null) {
        print(response.responseObject);
    }
  }

}
