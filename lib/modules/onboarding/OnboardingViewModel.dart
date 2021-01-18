import 'dart:async';
import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:flutter/foundation.dart';

abstract class OnboardingViewModelContract {
  Stream<AutheticationState> currentAuthState();
  void signOut();
}

class OnboardingViewModelContract extends OnboardingViewModelContract {

  final AutheticatingServicing _authenticationService = AutheticationService.shared;

  void signOut() {
    _authenticationService.signOut();
  }

}