import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopapp/components/InputField.dart';
import 'package:shopapp/constants.dart' as Const;
import 'package:shopapp/services/authenticate.dart';
import 'package:validators/sanitizers.dart';
import 'package:validators/validators.dart';

class AddQuestion extends StatefulWidget {
  final int productID;

  AddQuestion({Key key, @required this.productID}) : super(key: key);
  @override
  State<StatefulWidget> createState() => AddQuestionState();

}
class AddQuestionState extends State<AddQuestion> {
  Map detail;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController textController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          Container(
              decoration: BoxDecoration( color: Colors.white,),
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: ListView(
                //alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Text('پرسش خود را در مورد محصول مطرح کنید',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 10,),
                          InputFieldArea(
                              controller: textController,
                              obscure: false,maxLines: 5,
                              // ignore: missing_return
                              validator: (String value) {if(!isLength(value, 5)) {
                                return 'متن نباید کمتر از 5کاراکتر باشد';
                              }}
                          ),
                        ],
                      )
                  )
                ],
              )
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: deviceSize.width,
                height: 50,
                padding: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: Const.LayoutColor,
                 // borderRadius: BorderRadius.circular(3),
                ),
                child: FlatButton(
                    onPressed: () async{
                      if(_formKey.currentState.validate()) {
                        //_formKey.currentState.save();
                        storeQuestionData();
                        //_formKey.currentState.reset();
                        FocusScope.of(context).unfocus();
                      }
                    },
                    child: Center(child: Text(' ثبت پرسش ', style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w400)))
                ),
              )
            ],
          )
        ],
      )

    );
  }

  storeQuestionData() async {
    Map response = await AuthService.sendDataToServer({
      "pid": widget.productID.toString(),
      "text": textController.text,
    },'storeQuestionData');
    if(response == null) { // Connection Failed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }else if(response['status']) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('با موفقیت ثبت شد',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.green,
          )
      );
      Timer(Duration(seconds: 3), () {
        // 5s over, navigate to a new page
        Navigator.pop(context);
      });

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