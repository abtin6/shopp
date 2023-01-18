import 'dart:async';

import 'package:flutter/material.dart';
import 'package:persian_numbers/persian_numbers.dart';
import 'package:shopapp/components/InputField.dart';
import 'package:shopapp/pages/profile/setPassword.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:shopapp/constants.dart' as Const;

class AccountCodeVerify extends StatefulWidget {
  final String tel;

  AccountCodeVerify({Key key, @required this.tel}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AccountCodeVerifyState();

}
class AccountCodeVerifyState extends State<AccountCodeVerify> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController codeController = new TextEditingController();
  bool timeDone = false;

  Timer _timer;
  int _start = Const.TimerLength;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec,
          (Timer timer) => setState(() {
          if (_start < 1) {
            timer.cancel();
            timeDone = true;
          } else _start = _start - 1;
        },
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    startTimer();
    super.initState();
  }
  @override
  void dispose() {
    _timer.cancel();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: GestureDetector(onTap: (){ Navigator.pop(context); },child: Icon(Icons.arrow_back,color:  Color(0xFF424750))),
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
                  child: Text('کد تایید را وارد نمایید',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.black),),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('کد تایید برای شماره موبایل ${widget.tel} ارسال گردید',style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400),),
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        InputFieldArea(
                            controller: codeController,
                            hint: 'کد تایید', obscure: false, icon: Icons.mail_outline,
                            // ignore: missing_return
                            validator: (String value) {
                              var val = PersianNumbers.toEnglish(value);
                              if(!RegExp(r"09[0-9]{9}").hasMatch(val)) {
                              return 'کد وارد شده صحیح نمی باشد';
                            }}
                        ),
                      ],
                    )
                )
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                    onTap: () async{
                      if(_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        checkVerifyCode();
                        _formKey.currentState.reset();
                        FocusScope.of(context).unfocus();
                        startTimer();
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        ! timeDone
                            ? Center(child: Text('ارسال مجدد تا $_start ثانیه دیگر', style: TextStyle(color: Colors.black26,fontSize: 15,fontWeight: FontWeight.bold)))
                            : FlatButton(
                            onLongPress: null,
                            onPressed: () {
                              AuthService.sendDataToServer({ "tel": widget.tel, 'renew': 'again'},'checkAuthCode');
                              setState(() {
                                _start = Const.TimerLength;
                                timeDone = false;
                                startTimer();
                              });
                            },
                            child: Text('ارسال مجدد',style: TextStyle(fontWeight: FontWeight.bold,color: Const.LayoutColor))
                        )
                        ,
                      ],
                    )
                ),
                Container(
                  width: deviceSize.width,
                  height: 50,
                  padding: EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Const.LayoutColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FlatButton(
                      onPressed: () async{
                        checkVerifyCode();
                      },
                      child: Center(child: Text('تایید ', style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w400)))
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  checkVerifyCode() async {
    Map response = await AuthService.sendDataToServer({ "tel": widget.tel, "code": PersianNumbers.toEnglish(codeController.text)},'checkAuthCode');
    if(response == null) { // Connection Failed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }else if(response['status']) {
      Navigator.pushReplacementNamed(context, '/setPassword');
      Navigator.push(context, MaterialPageRoute(builder: (context) => SetPassword(tel : widget.tel)));
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