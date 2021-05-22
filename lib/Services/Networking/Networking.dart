import 'dart:convert';
import 'package:Whiff/model/WhiffError.dart';
import 'package:http/http.dart' as http;
import 'package:Whiff/Services/Networking/ServerResponse.dart';
import 'dart:io';



enum RequestMethod {
  get,
  post,
  delete
}

abstract class NetworkingServicing {
  Future<ServerResponse<Map<String, dynamic>>> makeRequest(RequestMethod method, String url, Map<String, String> body, String authHeader) async { }
  String getTermsOfServiceUrl();
  String getPrivacyPolicyUrl();

}

class NetworkService extends NetworkingServicing {

  final _kMainAdress = "https://whiffapp.herokuapp.com";

  static final NetworkService shared = NetworkService._internal();
  factory NetworkService() {
    return shared;
  }

  NetworkService._internal();

  Future<ServerResponse<Map<String, dynamic>>> makeRequest(RequestMethod method, String url, Map<String, String> body, String authHeader) async {
    switch(method){
      case RequestMethod.get:{
        var adress = _kMainAdress + url + "?";
        body.forEach((key, value) {
            adress = adress + key + "=" + value + "&";
        });
        if (adress != null && adress.length > 0) {
          adress = adress.substring(0, adress.length - 1);
        }
        try {
          final response = await http.get(adress,
            headers: <String, String>{ 'Authorization': authHeader},
          );
          if (response.statusCode > 205 || response.statusCode < 200) {
            return ServerResponse(null, WhiffError(
                response.statusCode, jsonDecode(response.body)["message"]));
          } else {
            Map<String, dynamic> decodedData = await jsonDecode(response.body);
            return ServerResponse(decodedData, null);
          }
        } on SocketException {
          print('No Internet connection 😑');
          return ServerResponse(null, WhiffError.noInternet());
        } on HttpException {
          print("Couldn't find the post 😱");
          return ServerResponse(null, WhiffError.noInternet());
        } on FormatException {
          return ServerResponse(null, WhiffError.noInternet());
        }

      }
      break;
      case RequestMethod.post: {
        try {
          final response = await http.post(_kMainAdress + url,
                                           body: body,
                                           headers: <String, String> { 'Authorization': authHeader },
          );
          if(response.statusCode > 205 || response.statusCode < 200) {
            return ServerResponse(null, WhiffError(response.statusCode,jsonDecode(response.body)["message"]));
          } else {
            Map<String, dynamic> decodedData = await jsonDecode(response.body);
            return ServerResponse(decodedData,null);
        }
        } on SocketException {
          print('No Internet connection 😑');
          return ServerResponse(null, WhiffError.noInternet());
        } on HttpException {
          print("Couldn't find the post 😱");
          return ServerResponse(null, WhiffError.noInternet());
        } on FormatException {
          return ServerResponse(null, WhiffError.noInternet());
        }
      }
      break;
      case RequestMethod.delete: {
        var adress = _kMainAdress + url + "?";
        body.forEach((key, value) {
          adress = adress + key + "=" + value + "&";
        });
        if (adress != null && adress.length > 0) {
          adress = adress.substring(0, adress.length - 1);
        }
        try {
           final response = await http.delete(adress,
                                               headers: <String, String> { 'Authorization': authHeader},);
            if(response.statusCode > 205 || response.statusCode < 200) {
              return ServerResponse(null, WhiffError(response.statusCode,jsonDecode(response.body)["message"]));
            } else {
              Map<String, dynamic> decodedData = await jsonDecode(response.body);
              return ServerResponse(decodedData,null);
            }
        } on SocketException {
          print('No Internet connection 😑');
          return ServerResponse(null, WhiffError.noInternet());
        } on HttpException {
          print("Couldn't find the post 😱");
          return ServerResponse(null, WhiffError.noInternet());
        } on FormatException {
          return ServerResponse(null, WhiffError.noInternet());
        }
      }
    }
  }

  String getTermsOfServiceUrl() {
    return _kMainAdress + "/public/termsOfService.pdf";
  }

  String getPrivacyPolicyUrl() {
    return _kMainAdress + "/public/privacypolicy.pdf";
  }
}

