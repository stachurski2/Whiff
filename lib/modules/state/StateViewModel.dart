import 'dart:async';
import 'package:Whiff/Services/Networking/ServerResponse.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/model/AirState.dart';
import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Data/DataService.dart';

abstract class StateViewModelContract {
  Stream<AutheticationState> currentAuthState();

  Stream<AirState> currentState();

  String signedInEmail();

  void signOut();

  void fetchState();

}

class StateViewModel extends StateViewModelContract {

  final AutheticatingServicing _authenticationService = AutheticationService.shared;
  final DataServicing _dataService = DataService.shared;

  Stream<AutheticationState> currentAuthState() {
    return _authenticationService.currentAuthState();
  }

  Stream<AirState> currentState() {
    return _dataService.currentState().map((serverResponse){
      return serverResponse.responseObject;
    }).where((responseObject){
      return responseObject != null;
    });
  }

  String signedInEmail() {
    return _authenticationService.signedInEmail();
  }

  void signOut() {
    _authenticationService.signOut();
  }

  void fetchState() {
    _dataService.fetchState();
  }
}