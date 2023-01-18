import 'package:flutter/material.dart';
import 'package:shopapp/services/authenticate.dart';

class DescScreen extends StatefulWidget {
  final String text;

  DescScreen({Key key, @required this.text}) : super(key: key);
  @override
  State<StatefulWidget> createState() => DescScreenState();

}
class DescScreenState extends State<DescScreen> {

  @override
  Widget build(BuildContext context) {
    if(widget.text == null || widget.text.length == 0)
      return Scaffold(body: Center(child: CircularProgressIndicator(),),);
    else
      return Scaffold(
        appBar: AppBar(
          title: Text('نقد و بررسی',style: TextStyle(fontSize: 16),),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              Text('${widget.text}',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color: Colors.black87,height: 2.1,),
              )
            ],
          ),
        ),
      );
  }

}