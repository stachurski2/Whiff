import 'dart:async';
import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:flutter/foundation.dart';

abstract class LoginViewModelContract {

  Stream<AutheticationState> currentAuthState();
  void setLogin(String login);
  void setPassword(String password);
  void login();
}

class LoginViewModel extends LoginViewModelContract {

  var _login = "";
  var _password = "";
  var _loginMessage = "";

  final AutheticatingServicing _authenticationService = AutheticationService.shared;

    @override
    Stream<AutheticationState> currentAuthState() {
       return _authenticationService.currentAuthState();
    }

  void setLogin(String login) {
      _login = login;
  }

  void setPassword(String password) {
      _password = password;
  }

  void login() {
      _authenticationService.login(_login, _password);
  }

}