import 'dart:async';
import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:rxdart/rxdart.dart';

enum LoginViewState {
  loginUser,
  registerUser,
  remindPassword
}

abstract class LoginViewModelContract {

  Stream<AutheticationState> currentAuthState();
  Stream<LoginViewState> curentViewState();

  void setLogin(String login);
  void setPassword(String password);
  void setSecondPassword(String password);
  void login();
  void requestRegisterUser();
  void requestRemindPassword();
  void remindPassword();
  void registerUser();
}

class LoginViewModel extends LoginViewModelContract {

  var _login = "";
  var _password = "";
  var _secondPassword = "";
  var _loginMessage = "";

  final AutheticatingServicing _authenticationService = AutheticationService.shared;

  final _stateSubject = PublishSubject<LoginViewState>();

  LoginViewModel() {
    _stateSubject.add(LoginViewState.loginUser);
  }

  @override
    Stream<AutheticationState> currentAuthState() {
       return _authenticationService.currentAuthState();
    }

    @override
    Stream<LoginViewState> curentViewState() {
        return _stateSubject.stream;
    }

  void setLogin(String login) {
      _login = login;
  }

  void setPassword(String password) {
      _password = password;
  }

  void setSecondPassword(String password) {
    _secondPassword = password;
  }


  void login() {
      _authenticationService.login(_login, _password);
  }

  void remindPassword() {
       _stateSubject.add(LoginViewState.remindPassword);
  }

  void registerUser() {
       _stateSubject.add(LoginViewState.registerUser);
  }

  void requestRegisterUser() {
        if(_password == _secondPassword) {
          _authenticationService.register(_login, _password);
        } else {
            print("show error");
        }
  }

  void requestRemindPassword() {
       _authenticationService.remindPassword(_login);
       _stateSubject.add(LoginViewState.loginUser);
  }
}