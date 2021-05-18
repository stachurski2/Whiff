class AutheticationState {
  String errorMessage;
  bool signedIn;
  bool newUser;

  AutheticationState(bool signedIn, String message, bool newUser) {
    this.errorMessage = message;
    this.signedIn = signedIn;
    this.newUser = newUser;
  }
}