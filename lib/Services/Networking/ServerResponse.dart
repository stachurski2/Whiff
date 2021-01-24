import 'package:Whiff/model/WhiffError.dart';

class ServerResponse<T extends Object> {
  T responseObject;
  WhiffError error;

  ServerResponse(this.responseObject,  this.error);
}