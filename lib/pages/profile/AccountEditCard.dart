import 'dart:async';

import 'package:flutter/material.dart';
import 'package:persian_numbers/persian_numbers.dart';
import 'package:shopapp/components/InputField.dart';
import 'package:shopapp/models/user.dart';
import 'package:shopapp/pages/profile/AccountInfo.dart';
import 'package:shopapp/pages/profile/setPassword.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:shopapp/constants.dart' as Const;
import 'package:validators/validators.dart';

class AccountEditCard extends StatefulWidget {
  final String Card;

  AccountEditCard({Key key, @required this.Card}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AccountEditCardState();

}
class AccountEditCardState extends State<AccountEditCard> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController CardController = new TextEditingController();
  UserInfo userInfo;

  @override
  void initState() {
    // TODO: implement initState
    CardController = new TextEditingController(text: widget.Card);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: GestureDetector(onTap: (){ Navigator.pop(context); },child: Icon(Icons.close,color:  Color(0xFF424750))),
          )
        ],
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
                  child: Text('?????????? ???????? ?????? ???? ???????? ????????????',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600,color: Colors.black),),
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        InputFieldArea(
                            controller: CardController,
                            obscure: false,
                            // ignore: missing_return
                            validator: (String value) {
                              var val = PersianNumbers.toEnglish(value);
                              if(!isLength(val, 2)) {
                              return '???????? ?????????? ???????? ???????? ???????? ????????';
                            }}
                        ),
                      ],
                    )
                )
              ],
            ),
            Column(
              children: <Widget>[
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
                        if(_formKey.currentState.validate()) {
                          //_formKey.currentState.save();
                          storeUserData();
                          //_formKey.currentState.reset();
                          FocusScope.of(context).unfocus();
                        }
                      },
                      child: Center(child: Text('?????????? ?????????????? ', style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w400)))
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  storeUserData() async {
    Map response = await AuthService.sendDataToServer({ "card": CardController.text},'storeUserInfo');
    if(response == null) { // Connection Failed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('?????? ???? ?????????????? ???????????? ???? ????????',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }else if(response['status']) {
      Navigator.push (context, MaterialPageRoute( builder: (BuildContext context) => AccountInfoScreen() ) );
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