import 'package:Whiff/Services/Networking/Networking.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';

abstract class AutheticatingServicing {
  Future<AutheticationState> login(String email, String password) async { }
}

class AutheticationService extends AutheticatingServicing  {

  static final AutheticationService shared = AutheticationService._internal();
  factory AutheticationService() {
    return shared;
  }

  AutheticationService._internal();

  NetworkingServicing networkService = NetworkService.shared;

  final kMainAdress = "https://whiffdev.herokuapp.com";

  var _authorizationMethod = "";
  var _authorizationToken = "";

  String authorizationHeader() {
    return _authorizationMethod + " " + _authorizationToken;
  }

  Future<AutheticationState> login(String email, String password) async {
        email = email.replaceAll(' ', '');
        var response = await networkService.makeRequest(RequestMethod.post, kMainAdress + "/loginUser", { "email": email, "password": password}, null);
          if(response.responseObject != null && response.responseObject["token"] != null && response.responseObject["authMethod"] != null) {
            print(response.responseObject);
            this._authorizationMethod = response.responseObject["authMethod"];
            this._authorizationToken = response.responseObject["token"];
            return AutheticationState(true, null);
          } else if(response.errorMessage != null) {
            return AutheticationState(false, response.errorMessage);
          } else {
            return AutheticationState(false, null);;
          }
  }
}


