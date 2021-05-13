

class WhiffError extends Error {

  final int sensorNumber;
  final int errorCode;
  final String errorMessage;

  WhiffError(this.errorCode, this.errorMessage, { this.sensorNumber });

  static WhiffError noInternet()  {
    return WhiffError(1001, "error_no_internet_connection");
  }

  static WhiffError serverUnavailable()  {
    return WhiffError(1002, "error_server_unavailable");
  }

  static WhiffError responseDecodeProblem()  {
    return WhiffError(1002, "error_server_response_decode_problem");
  }

  bool isLocalError() {
    return ((errorCode == 1001) || (errorCode == 1002) || (errorCode == 1003));
  }

}