import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:persian_numbers/persian_numbers.dart';
import 'package:shopapp/components/InputField.dart';
import 'package:shopapp/services/authenticate.dart';

import 'package:shopapp/pages/profile/AccountCodeVerify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shopapp/constants.dart' as Const;

class CreateAccount extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreateAccountState();

}
class CreateAccountState extends State<CreateAccount> with TickerProviderStateMixin {
  @override
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController telController = new TextEditingController();
  AnimationController _BtnController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _BtnController = AnimationController(vsync: this, duration: Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _BtnController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return WillPopScope(
        child: Scaffold(
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
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: GestureDetector(
                          onTap: () async{
                            /*if (await canLaunch(Const.PRIVACY_URL))*/ await launch(Const.PRIVACY_URL);
                            //else throw 'Could not launch ${item['url']}';
                          },
                          child: Text('سیاست حفظ حریم خصوصی (Privacy policy)',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.blueAccent),),
                        ),
                      ),
                    )
                  ],
                ),
                GestureDetector(
                    onTap: () async{
                      if(_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        sendVerifyCode();
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
                      child: Center(child: Text('ادامه', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold))),
                    )
                ),
              ],
            ),
          ),
        ),
        onWillPop: () {
          //trigger leaving and use own data
          Navigator.of(context).pushReplacementNamed('/login');
          //we need to return a future
          return Future.value(false);
        }
    );
  }

  sendVerifyCode() async {
    Map response = await AuthService.sendDataToServer({ "tel": PersianNumbers.toEnglish(telController.text)},'register');
    if(response == null) { // Connection Failed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }else if(response['status']) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AccountCodeVerify(tel : telController.text)));
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['result']['message'],style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }
  }

}