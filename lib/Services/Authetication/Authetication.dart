import 'package:Whiff/Services/Networking/Networking.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AutheticatingServicing {
  Future<AutheticationState> login(String email, String password) async { }
  String authorizationHeader();
  String signedInEmail();
  Stream<AutheticationState> currentAuthState();
  void signOut();
}

class AutheticationService extends AutheticatingServicing  {


  AutheticationService._internal() {
    _readStoredCredientials();
  }

  NetworkingServicing networkService = NetworkService.shared;

  final _kMainAdress = "https://whiffdev.herokuapp.com";
  final _kAuthTokenKey = "AuthTokenKey";
  final _kAuthMethodKey = "AuthMethodKey";
  final _kEmailKey = "EmailKey";

  var _authorizationMethod = "";
  var _authorizationToken = "";
  var _signedInEmail = "";
  var _didRequestLogin = false;

  static final AutheticationService shared = AutheticationService._internal();
  factory AutheticationService() {
    return shared;
  }

  final _subject = PublishSubject<AutheticationState>();

  String authorizationHeader() {
    return _authorizationMethod + " " + _authorizationToken;
  }

  String signedInEmail() {
    return _signedInEmail;
  }

  Stream<AutheticationState> currentAuthState() {
    return _subject.stream;
  }

  void signOut() {
    var _authorizationMethod = "";
    var _authorizationToken = "";
    var _signedInEmail = "";
    _removeStoredCredientials();
    _subject.add( AutheticationState(false, null));
  }

  Future<AutheticationState> login(String email, String password) async {
        email = email.replaceAll(' ', '');
        _didRequestLogin = true;
        var response = await networkService.makeRequest(RequestMethod.post, _kMainAdress + "/loginUser", { "email": email, "password": password}, null);
        _didRequestLogin = false;
        if(response.responseObject != null && response.responseObject["token"] != null && response.responseObject["authMethod"] != null) {
            print(response.responseObject);
            this._authorizationMethod = response.responseObject["authMethod"];
            this._authorizationToken = response.responseObject["token"];
            this._signedInEmail = email;
            final state = AutheticationState(true, null);
            _subject.add(state);
            _storeCredientials();
            return AutheticationState(true, null);
          } else if(response.errorMessage != null) {
           final state = AutheticationState(false, response.errorMessage);
            _subject.add(state);
            return state;
          } else {
            final state = AutheticationState(false, null);
            return state;
          }
  }



  _storeCredientials() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_kAuthTokenKey, _authorizationToken);
    prefs.setString(_kAuthMethodKey, _authorizationMethod);
    prefs.setString(_kEmailKey, _signedInEmail);
  }

  _readStoredCredientials() async {
    final prefs = await SharedPreferences.getInstance();
    _authorizationToken = prefs.getString(_kAuthTokenKey);
    _signedInEmail = prefs.getString(_kEmailKey);
    _authorizationMethod = prefs.getString(_kAuthMethodKey);

    if(_authorizationToken != null && _authorizationMethod != null ) {
      if (_authorizationToken.length > 0 && _authorizationMethod.length > 0) {
        _subject.add(AutheticationState(true, null));
      }
    }
  }


  _removeStoredCredientials() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_kEmailKey);
    prefs.remove(_kAuthTokenKey);
    prefs.remove(_kAuthMethodKey);
  }

}


