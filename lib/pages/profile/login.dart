import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:persian_numbers/persian_numbers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/animations/button_animation.dart';
import 'package:shopapp/components/Form.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:shopapp/constants.dart' as Const;

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginScreenState();

}
class LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // ignore: non_constant_identifier_names
  AnimationController _LoginBtnController;
  final _formKey = GlobalKey<FormState>();
  //final _textFieldController = TextEditingController()
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _telValue;
  String _passwordValue;

  telOnSaved(String value) {
    _telValue = value;
  }
  passwordOnSaved(String value) {
    _passwordValue = value;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _LoginBtnController = AnimationController(vsync: this, duration: Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _LoginBtnController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      primary: Colors.white,
      minimumSize: Size(88, 44),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),
      backgroundColor: Colors.white,
    );
    timeDilation = .5;
    var page = MediaQuery.of(context).size;
    return WillPopScope(
        child: Scaffold(
            //resizeToAvoidBottomPadding: false,
            resizeToAvoidBottomInset: false,
            key: _scaffoldKey,
            body: Container(
              decoration: BoxDecoration( color: Colors.white,),
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: ListView(
                //alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        //GestureDetector(onTap: (){ Navigator.pushReplacementNamed(context, '/setting');},child: Icon(Icons.settings,color: Color(0xFF424750))),
                        GestureDetector(onTap: (){ Navigator.pushReplacementNamed(context, '/home');},child: Icon(Icons.home,color:  Color(0xFF424750))),
                      ],
                    ),
                  ),
                  Image.asset('assets/images/store.png',fit: BoxFit.scaleDown,width: 200,height: 200,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FormContainer(
                        formkey : _formKey,
                        telOnSaved: telOnSaved,
                        passwordOnSaved: passwordOnSaved,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          TextButton(
                              style: flatButtonStyle,
                              onPressed: () {Navigator.pushReplacementNamed(context, '/ForgotPassword');},
                              child: Text('رمزعبور خود را فراموش کردید؟ >',style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF55D4E3)),)
                          )
                        ],
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () async{
                      //_formKey.currentState.reset();
                      if(_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        sendDataForLogin();
                        //await _LoginBtnController.forward();
                        //await _LoginBtnController.reverse();
                      }
                    },
                    child: buttonAnimation( controller: _LoginBtnController.view, label: 'ورود',),
                  ),
                  TextButton(
                      style: flatButtonStyle,
                      onLongPress: null,
                      onPressed: () {Navigator.pushReplacementNamed(context, '/CreateAccount');},
                      child: Text('ساخت حساب کاربری جدید',style: TextStyle(fontWeight: FontWeight.bold,color: Const.LayoutColor),)
                  )
                ],
              ),
            )
        ),
        onWillPop:  () {
          //trigger leaving and use own data
          Navigator.of(context).pushReplacementNamed('/home');
          //we need to return a future
          return Future.value(false);
        }
    );
  }

  sendDataForLogin() async {
    await _LoginBtnController.animateTo(0.150);
    Map response = await AuthService.sendDataToServer({ "tel": PersianNumbers.toEnglish(_telValue), "password": PersianNumbers.toEnglish(_passwordValue)},'login');
    if(response == null) { // Connection Failed
      await _LoginBtnController.reverse();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }else if(response['status']) {
      // sharedPreferences
      await storeUserData(response['result']['data']);
      //Navigator.pushReplacementNamed(context, '/profile');
      Navigator.pushReplacementNamed(context, '/home');
    }else {
      await _LoginBtnController.reverse();
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
    await prefs.setString('user.api_token', userData['api_token']);
    //await prefs.setInt('user.userid', userData['user_id']);
  }

}