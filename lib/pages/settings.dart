import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/animations/button_animation.dart';
import 'package:shopapp/components/Form.dart';
import 'package:shopapp/services/authenticate.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingScreenState();

}
class SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('تنظیمات',style: TextStyle(fontSize: 16),),
        centerTitle: true,
        actions: <Widget>[
          GestureDetector(onTap: (){ Navigator.pushReplacementNamed(context, '/home');},child: Icon(Icons.close,color:  Color(0xFF424750))),
        ],
      ),
      body: Center(child: Text('تنظیمات'),),
    );
  }

}