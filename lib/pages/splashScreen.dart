import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shopapp/helper.dart';
import 'package:shopapp/constants.dart' as Const;

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashScreenState();

}
class SplashScreenState extends State<SplashScreen> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  /*startTime() {
    var _duration = Duration(seconds: 5);
    return Timer(_duration, navigationToLogin);
  }*/

  navigationToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }
  navigationToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //startTime();
    checkNetworkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Const.SplashScreenColor,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/images/logo.png')),

                ),
              ),
              Text(Const.SplashScreenText, style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),

            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Align(alignment: Alignment.bottomCenter, child: CircularProgressIndicator(backgroundColor: Colors.white,),) ,
          )
        ],
      )
    );

  }
  checkNetworkConnection() async{
    if( await checkConnectionInternet()) {
      await Future.delayed(Duration(seconds: Const.SplashScreenWait));
      navigationToHome();
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              duration: Duration(hours: 2),
              content: GestureDetector(
                onTap: (){ _scaffoldKey.currentState.hideCurrentSnackBar(); checkNetworkConnection(); },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('از اتصال دستگاه به اینترنت مطمئن شوید!', style: TextStyle(fontFamily: 'Vazir'),),
                    Icon(Icons.wifi_lock, color: Colors.white,)
                  ],
                ),
              )
          )
      );
    }
    //await prefs.remove('user.api_token'); // remove a key
  }


}