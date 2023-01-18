import 'dart:async';

import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:shopapp/models/user.dart';
import 'package:shopapp/pages/profile/AccountEditCard.dart';
import 'package:shopapp/pages/profile/AccountEditEmail.dart';
import 'package:shopapp/pages/profile/AccountEditName.dart';
import 'package:shopapp/pages/profile/AccountEditPassword.dart';
import 'package:shopapp/pages/profile/profile.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:validators/validators.dart';

import 'AccountEditMcode.dart';

// ignore: must_be_immutable
class AccountInfoScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => AccountInfoState();

}
class AccountInfoState extends State<AccountInfoScreen> {
  UserInfo userInfo;
  final GlobalKey<AsyncLoaderState> _asyncLoaderState = GlobalKey<AsyncLoaderState>();

  _fetchUser() async{
    var response = await AuthService.getUserInfo();
    setState(() {
      userInfo = userInfoFromJson(response.toString());
    });
  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var _asyncLoader = new AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await _fetchUser(),
        renderLoad: () => Center(child: CircularProgressIndicator(),),
        renderError: ([error]) => Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontSize: 16),),
            FlatButton(
                color: Colors.red,
                child: Text("تلاش دوباره", style: TextStyle(color: Colors.white),),
                onPressed: () => _asyncLoaderState.currentState.reloadState())
          ],
        )),
        renderSuccess: ({data}) => Container(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => AccountEditName(name: isLength(userInfo.name, 1) ? userInfo.name : 'بدون نام')));},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('نام و نام خانوادگی',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500,color: Color(0xff95989D)),),
                        Text(isLength(userInfo.name, 1) ? userInfo.name : 'بدون نام',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600,color: Color(0xff464B53)),),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 17,),
                  ],
                ),
              ),
              Divider(),
              GestureDetector(
                onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => AccountEditMcode(mcode: userInfo.mcode)));},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('کدملی',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500,color: Color(0xff95989D)),),
                        Text(userInfo.mcode,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600,color: Color(0xff464B53)),),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 17,),
                  ],
                ),
              ),
              Divider(),
              GestureDetector(
                onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => AccountEditCard(Card: userInfo.card)));},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('شماره کارت',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500,color: Color(0xff95989D)),),
                        Text(userInfo.card,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600,color: Color(0xff464B53)),),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 17,),
                  ],
                ),
              ),
              Divider(),
              GestureDetector(
                onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => AccountEditEmail(Email: userInfo.email)));},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('پست الکترونیک',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500,color: Color(0xff95989D)),),
                        Text(userInfo.email,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600,color: Color(0xff464B53)),),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 17,),
                  ],
                ),
              ),
              Divider(),
              GestureDetector(
                onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => AccountEditPassword()));},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('رمزعبور',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500,color: Color(0xff95989D)),),
                        Text('**********',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600,color: Color(0xff464B53)),),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 17,),
                  ],
                ),
              ),
              Divider(),
            ],
          ),
        )
    );
      return Scaffold(
      appBar: AppBar(
        title: Text('اطلاعات حساب کاربری'),
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () { Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProfileScreen() ) );},
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: _asyncLoader,
    );
  }

}