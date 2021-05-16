import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/Services/Data/DataService.dart';
import 'package:Whiff/Services/Networking/ServerResponse.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:Whiff/model/WhiffError.dart';

abstract class AccountSettingsViewModelContract {
  Stream<AutheticationState> currentAuthState();
  Stream<List<Sensor>> sensorsList();
  Stream<WhiffError> sensorsListFetchError();
  Stream<ServerResponse<bool>> changePasswordResult();

  String signedInEmail();
  void signOut();
  void fetchSensors();
  void setFirstPassword(String password);
  void setSecondPassword(String password);
  void requestPasswordChange();

  String getTermsOfServiceUrl();
  String getPrivacyPolicy();
}

class AccountSettingsViewModel extends AccountSettingsViewModelContract {

  var _firstPassword = "";
  var _secondPassword = "";

  final AutheticatingServicing _authenticationService = AutheticationService.shared;
  final DataServicing _dataService = DataService.shared;
  final _innerChangePasswordSubject = PublishSubject<ServerResponse<bool>>();

  void signOut() {
    _authenticationService.signOut();
  }

  String signedInEmail() {
      return _authenticationService.signedInEmail();
  }

  Stream<AutheticationState> currentAuthState() {
    return _authenticationService.currentAuthState();
  }

  void fetchSensors() {
    _dataService.fetchSensors();
  }

  Stream<List<Sensor>> sensorsList() {
    return _dataService.fetchedSensors().map((serverResponse){
        return serverResponse.responseObject;
    });
  }
  Stream<WhiffError> sensorsListFetchError() {
    return _dataService.fetchedSensors().map((serverResponse){
      return serverResponse.error;
    });
  }

  void setFirstPassword(String password) {
    _firstPassword = password;
  }
  void setSecondPassword(String password) {
    _secondPassword = password;
  }
  void requestPasswordChange() {
    if(_firstPassword == _secondPassword) {
      if(_firstPassword.length < 6) {
        _innerChangePasswordSubject.add(ServerResponse(false, WhiffError(1003,"login_login_password_do_too_short")));
      } else {
        _authenticationService.changePassword(_firstPassword);
      }
    } else {
      _innerChangePasswordSubject.add(ServerResponse(false, WhiffError(1002,"login_login_passwords_do_not_match")));
    }
  }

  Stream<ServerResponse<bool>> changePasswordResult() {
    return _authenticationService.changePasswordState().mergeWith([_innerChangePasswordSubject.stream]).doOnData((event) {
      this.setFirstPassword("");
      this.setSecondPassword("");
    });
  }

  String getTermsOfServiceUrl() {
    return _dataService.getTermsOfServiceUrl();
  }

  String getPrivacyPolicy() {
    return _dataService.getPrivacyPolicyUrl();
  }


}