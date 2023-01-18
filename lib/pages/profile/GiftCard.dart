import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shopapp/components/InputField.dart';
import 'package:shopapp/pages/profile/AccountCodeVerify.dart';
import 'package:shopapp/services/authenticate.dart';

class GiftCardScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GiftCardScreenState();

}
class GiftCardScreenState extends State<GiftCardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('کارت هدیه'),
        leading: GestureDetector(onTap: (){ Navigator.pop(context); },child: Icon(Icons.arrow_back,color:  Color(0xFF424750))),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/giftcard.png'),
            Text('موردی برای نمایش وجود ندارد!')
          ],
        ),
      ),
    );
  }

}