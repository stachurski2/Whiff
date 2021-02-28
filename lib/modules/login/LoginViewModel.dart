import 'dart:async';
import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/model/WhiffError.dart';

import 'package:rxdart/rxdart.dart';


enum LoginViewState {
  loginUser,
  registerUser,
  remindPassword,
  loading
}

abstract class LoginViewModelContract {

  Stream<AutheticationState> currentAuthState();
  Stream<LoginViewState> curentViewState();
  Stream<String> alertStream();


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
  final _alertSubject = PublishSubject<String>();

  LoginViewModel() {
    _stateSubject.add(LoginViewState.loginUser);
    _authenticationService.currentAuthState().listen((state) {
        _stateSubject.add(LoginViewState.loginUser);
    });
  }

  @override
    Stream<AutheticationState> currentAuthState() {
       return _authenticationService.currentAuthState();
    }

    @override
    Stream<LoginViewState> curentViewState() {
      Stream<LoginViewState> registrationState = _authenticationService.registrationState().map((error){
        return LoginViewState.registerUser;
      });
        return _stateSubject.stream.mergeWith([registrationState]);
    }

    @override
    Stream<String> alertStream() {
        Stream<String> messageErrorStream = _authenticationService.registrationState().map((error){
        if(error.errorMessage != null) {
            return error.errorMessage;
            } else {
            return "unknown_error_message";
            }
        });
        return _alertSubject.stream.mergeWith([messageErrorStream]);
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
    _stateSubject.add(LoginViewState.loading);
    _authenticationService.login(_login, _password);
  }

  void remindPassword() {
       _stateSubject.add(LoginViewState.remindPassword);
  }

  void registerUser() {
       _stateSubject.add(LoginViewState.registerUser);
  }

  void requestRegisterUser() {
    if(_isEmail(_login)) {
      if(_password.length > 5) {
        if (_password == _secondPassword) {
          _authenticationService.register(_login, _password);
          _stateSubject.add(LoginViewState.loading);
        } else {
          _alertSubject.add("login_login_passwords_do_not_match");
        }
      } else {
        _alertSubject.add("login_login_password_do_too_short");
      }
    } else {
      _alertSubject.add("login_login_incorrect_login_format");
    }
  }

  void requestRemindPassword() {
        if(_isEmail(_login)) {
          _authenticationService.remindPassword(_login);
          _stateSubject.add(LoginViewState.loading);
        } else {
          _alertSubject.add("login_login_incorrect_login_format");
        }
  }

  bool _isEmail(String phrase) {

    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(phrase);
  }
}