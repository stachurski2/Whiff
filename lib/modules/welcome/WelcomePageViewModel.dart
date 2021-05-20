import 'dart:async';
import 'package:Whiff/Services/Networking/ServerResponse.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/model/AirState.dart';
import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Data/DataService.dart';

abstract class WelcomePageViewModelContract {
  Stream<bool> demoState();
  Stream<String> demoErrorMessage();
  void requestDemo();
}

class WelcomePageViewModel extends WelcomePageViewModelContract {

  final AutheticatingServicing _authenticationService = AutheticationService.shared;
  final DataServicing _dataService = DataService.shared;

  Stream<AutheticationState> currentAuthState() {
    return _authenticationService.currentAuthState();
  }

  Stream<bool> demoState() {
    return _dataService.demoState().map((serverResponse){
      print("hehe");
      print(serverResponse.responseObject);
      if(serverResponse.responseObject == true) {
        return true;
      } else {
        return false;
      }
    });
  }


  Stream<String> demoErrorMessage() {
    return _dataService.demoState().map((serverResponse){
        if(serverResponse.error != null) {
          return serverResponse.error.errorMessage;
        }
    });
  }

  void requestDemo() {
    _dataService.requestDemo();
  }
}