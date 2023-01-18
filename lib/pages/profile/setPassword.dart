import 'dart:async';

import 'package:flutter/material.dart';
import 'package:persian_numbers/persian_numbers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/components/InputField.dart';
import 'package:shopapp/constants.dart' as Const;
import 'package:shopapp/services/authenticate.dart';

class SetPassword extends StatefulWidget {
  final String tel;

  SetPassword({Key key, this.tel}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SetPasswordState();

}
class SetPasswordState extends State<SetPassword> {
  @override
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController pwdController = new TextEditingController();


  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: GestureDetector(onTap: (){ Navigator.popAndPushNamed(context, '/login'); },child: Icon(Icons.arrow_back,color:  Color(0xFF424750))),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('رمزعبور خود را انتخاب کنید',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.black),),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('رمزعبور شما حداقل باید 6 حرف باشد',style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400),),
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        InputFieldArea(
                            controller: pwdController,
                            hint: '', obscure: false,  icon: Icons.lock_outline,
                            // ignore: missing_return
                            validator: (String value) {
                              var val = PersianNumbers.toEnglish(value);
                              if(val.length < 6) {
                              return 'رمزعبور شما حداقل 6 حرف یا عدد باشد';
                            }}
                        ),
                      ],
                    )
                )
              ],
            ),
            GestureDetector(
              onTap: () async{
                if(_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  setPassword();
                  //_formKey.currentState.reset();
                  FocusScope.of(context).unfocus();
                }
              },
              child: Container(
                width: deviceSize.width,
                height: 50,
                decoration: BoxDecoration(
                  color: Const.LayoutColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Center(child: Text('تایید', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold))),
              )
            ),
          ],
        ),
      ),
    );
  }

  setPassword() async {
    Map response = await AuthService.sendDataToServer({ "tel": widget.tel, 'password':  PersianNumbers.toEnglish(pwdController.text)},'setPassword');
    if(response == null) { // Connection Failed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }else if(response['status']) {
      await storeUserData(response['result']['data']);
      Navigator.pushReplacementNamed(context, '/profile');
      //Navigator.push(context, MaterialPageRoute(builder: (context) => SetPassword(tel : widget.tel)));
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['result']['message'],style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }
  }

  storeUserData(Map userData) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //if(!prefs.containsKey('user.api_token'))
      await prefs.setString('user.api_token', userData['api_token']);
    //await prefs.setInt('user.userid', userData['user_id']);
  }

}