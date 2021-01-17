class ServerResponse<T extends Object> {
  T responseObject;
  int errorCode;
  String errorMessage;

  ServerResponse(T responseObject, int errorCode, String message) {
    this.responseObject = responseObject;
    this.errorCode = errorCode;
    this.errorMessage = message;
  }
}