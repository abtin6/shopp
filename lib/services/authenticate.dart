import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/constants.dart' as Const;

class AuthService {
  static Future<Map> sendDataToServer(Map body, String method) async {
    try {
      var apiToken = await getApiToken();
      //print(Const.API_URL + '/$method?api_token=$apiToken&device=mobileapp&securitycode='+Const.SecurityCode);
      var url = Uri.parse(Const.API_URL + '/$method?api_token=$apiToken&device=mobileapp&securitycode='+Const.SecurityCode);
      final response = await http.post( url, body: body).timeout(
      //final response = await http.post( url,headers: {"content-type": "application/json",}, body: jsonEncode(body)).timeout(
        Duration(seconds: 10),
        onTimeout: () {return null;},
      );
      if (response.statusCode == 200) {
        if(response.body.isNotEmpty) {
          var responseBody = jsonDecode(response.body);
          return responseBody;
        }
      }else return null;
    } on SocketException catch(_){
      return null;
    }

  }
  static getUserInfo() async{
    var response =  await AuthService.sendDataToServer({}, 'getUserInfo');
    if(response['status']) {
      return response['result']['data'];
    }
  }
  static getApiToken() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('user.api_token'))
      return prefs.getString('user.api_token');
    else return 'False';
  }

}