import 'dart:async';

import 'package:flutter/material.dart';
import 'package:persian_numbers/persian_numbers.dart';
import 'package:shopapp/components/InputField.dart';
import 'package:shopapp/pages/profile/AccountCodeVerify.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:shopapp/constants.dart' as Const;

class ForgotPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ForgotPasswordState();

}
class ForgotPasswordState extends State<ForgotPassword> {
  @override
  final _formKey = GlobalKey<FormState>();
  TextEditingController telController = new TextEditingController();


  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return WillPopScope(
        child: Scaffold(
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
                      child: Text('شماره تلفن همراه خود را وارد نمایید',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.black),),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('یک کد، برای تایید این شماره برای شما ارسال خواهد شد',style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400),),
                    ),
                    Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            InputFieldArea(
                                controller: telController,
                                hint: 'شماره موبایل', obscure: false,  icon: Icons.phone_android,
                                // ignore: missing_return
                                validator: (String value) {
                                  var val = PersianNumbers.toEnglish(value);
                                  if(!RegExp(r"09[0-9]{9}").hasMatch(val)) {
                                    return 'فرمت شماره موبایل صحیح نیست';
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
                        await AuthService.sendDataToServer({ "tel": PersianNumbers.toEnglish(telController.text)},'register');
                        //_formKey.currentState.reset();
                        FocusScope.of(context).unfocus();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AccountCodeVerify(tel : PersianNumbers.toEnglish(telController.text))));
                      }
                    },
                    child: Container(
                      width: deviceSize.width,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Const.LayoutColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Center(child: Text('ارسال درخواست', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold))),
                    )
                ),
              ],
            ),
          ),
        ),
        onWillPop:  () {
          //trigger leaving and use own data
          Navigator.of(context).pushReplacementNamed('/login');
          //we need to return a future
          return Future.value(false);
        }
    );
  }

}