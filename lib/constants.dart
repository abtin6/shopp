library constants;
import 'package:flutter/material.dart';

// for Localhost use => 10.0.2.2
const String API_URL = "http://10.0.2.2/api/v1"; // without trailing-slash
const String SITE_URL = "http://10.0.2.2/"; // without trailing-slash
const int TimerLength = 180; // seconds
const int SplashScreenWait = 1; // seconds
const SplashScreenColor = Color(0xFFEF394E); // u can use : Colors.red
const String SplashScreenText = "فروشگاه اینترنتی";
const String ApplicationTitle = "فروشگاه نت پارادیس"; // Application runtime Title
const AccentColor = Colors.blueGrey; // Application swipe,indicator Color
const String PRIVACY_URL = "http://10.0.2.2/page/privacy"; // create page on adminpanel
const String SecurityCode = "5ir9V9PpVGVBj7hjC5bG02cwg7FBT4RW6HCl6srs35pgFlLQMJwasW59op32l1SEeDqXqpMV3IqCZoOmXyfPFvpNYio3s5SC1cSx"; // Same Value in App/Config.php
const LayoutColor = Color(0xFFEF394E)/*Colors.lightGreen*/; // App Main Color
// FlatButton Style
final ButtonStyle flatButtonStyle = TextButton.styleFrom(
  primary: Colors.white,
  minimumSize: Size(88, 44),
  padding: EdgeInsets.symmetric(horizontal: 16.0),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2.0)),
  ),
  backgroundColor: Colors.red,
);