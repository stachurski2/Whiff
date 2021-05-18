import 'package:Whiff/Services/Networking/Networking.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/Services/Networking/ServerResponse.dart';
import 'package:Whiff/model/WhiffError.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AutheticatingServicing {
  void login(String email, String password) async { }
  void register(String email, String password) async { }
  void remindPassword(String email) async { }
  void changePassword(String password) async { }

  String authorizationHeader();
  String signedInEmail();
  Stream<AutheticationState> currentAuthState();
  Stream<WhiffError> registrationState();
  Stream<ServerResponse<bool>> changePasswordState();

  void signOut();
}

class AutheticationService extends AutheticatingServicing  {

  AutheticationService._internal() {
    _readStoredCredientials();
  }

  NetworkingServicing networkService = NetworkService.shared;

  final _kAuthTokenKey = "AuthTokenKey";
  final _kAuthMethodKey = "AuthMethodKey";
  final _kEmailKey = "EmailKey";

  var _authorizationMethod = "";
  var _authorizationToken = "";
  var _signedInEmail = "";
  var _didRequestLogin = false;
  var _didRequestRegister = false;
  var _didRequestRemind = false;


  static final AutheticationService shared = AutheticationService._internal();
  factory AutheticationService() {
    return shared;
  }

  final _subject = PublishSubject<AutheticationState>();
  final _registrationErrorSubject = PublishSubject<WhiffError>();
  final _changePasswordSubject = PublishSubject<ServerResponse<bool>>();


  String authorizationHeader() {
    return _authorizationMethod + " " + _authorizationToken;
  }

  String signedInEmail() {
    return _signedInEmail;
  }

  Stream<AutheticationState> currentAuthState() {
    return _subject.stream;
  }

  Stream<WhiffError> registrationState() {
    return _registrationErrorSubject.stream;
  }


  void signOut() {
     _authorizationMethod = "";
     _authorizationToken = "";
     _signedInEmail = "";
    _removeStoredCredientials();
    _subject.add( AutheticationState(false, null, false));
  }

   void login(String email, String password) async {
        email = email.replaceAll(' ', '');
        _didRequestLogin = true;
        var response = await networkService.makeRequest(RequestMethod.post, "/loginUser", { "email": email, "password": password}, null);
        _didRequestLogin = false;
        if(response.responseObject != null && response.responseObject["token"] != null && response.responseObject["authMethod"] != null) {
            this._authorizationMethod = response.responseObject["authMethod"];
            this._authorizationToken = response.responseObject["token"];
            this._signedInEmail = email;
            final state = AutheticationState(true, null, false);
            _subject.add(state);
            _storeCredientials();
          } else if(response.error != null) {
           final state = AutheticationState(false, response.error.errorMessage, false);
            _subject.add(state);
          } else {
            final state = AutheticationState(false, null, false);
          }
  }

  void register(String email, String password) async {
       email = email.replaceAll(' ', '');
       _didRequestRegister = true;
       var response = await networkService.makeRequest(RequestMethod.post, "/registerUser", { "email": email, "password": password}, null);
       _didRequestRegister = false;
       if(response.responseObject == null) {
         if(response.error != null) {
           _registrationErrorSubject.add(response.error);
         } else {
           _registrationErrorSubject.add(
               WhiffError(0, "unknown_error_message"));
         }
       } else {
         if (response.responseObject["token"] != null) {
           this._authorizationToken = response.responseObject["token"];
           this._signedInEmail = email;
           this._authorizationMethod = "Basic";
           final state = AutheticationState(true, null, true);
           _subject.add(state);
           _storeCredientials();
         }

       }
    }

  void remindPassword(String email) async {
    email = email.replaceAll(' ', '');
    _didRequestRemind = true;
    var response = await networkService.makeRequest(RequestMethod.post, "/resetPassword", { "email": email }, null);
    _didRequestRemind = false;
    _subject.add( AutheticationState(false, null, false));
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
        _subject.add(AutheticationState(true, null, false));
      }
    }
  }


  _removeStoredCredientials() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_kEmailKey);
    prefs.remove(_kAuthTokenKey);
    prefs.remove(_kAuthMethodKey);
  }

  void changePassword(String password) async {
    var response = await networkService.makeRequest(
        RequestMethod.post, "/changePassword", { "password": password}, authorizationHeader());
    if (response.responseObject != null && response.responseObject["token"] != null) {
      _authorizationToken = response.responseObject["token"];
      _storeCredientials();
      _changePasswordSubject.add(ServerResponse(true, null));
    } else {
      if (response.error != null) {
        _changePasswordSubject.add(ServerResponse(false, response.error));
      } else {
        _changePasswordSubject.add(
            ServerResponse(false, WhiffError(0, "unknown_error_message")));
      }
    }
  }


  Stream<ServerResponse<bool>> changePasswordState() {
    return _changePasswordSubject;
  }

}


