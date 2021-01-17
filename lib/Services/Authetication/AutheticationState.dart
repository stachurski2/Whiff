class AutheticationState {
  String errorMessage;
  bool signedIn;

  AutheticationState(bool signedIn, String message) {
    this.errorMessage = message;
    this.signedIn = signedIn;
  }
}