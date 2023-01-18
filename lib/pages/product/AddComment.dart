import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopapp/components/InputField.dart';
import 'package:shopapp/constants.dart' as Const;
import 'package:shopapp/services/authenticate.dart';
import 'package:validators/sanitizers.dart';
import 'package:validators/validators.dart';

class AddComment extends StatefulWidget {
  final int productID;

  AddComment({Key key, @required this.productID}) : super(key: key);
  @override
  State<StatefulWidget> createState() => AddCommentState();

}
class AddCommentState extends State<AddComment> {
  Map detail;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController titleController = new TextEditingController();
  TextEditingController advController = new TextEditingController();
  TextEditingController disadvController = new TextEditingController();
  TextEditingController textController = new TextEditingController();
  List<String> adv = List<String>();
  List<String> disadv = List<String>();

  _getPDetail() async {
    Map response = await AuthService.sendDataToServer({'id': widget.productID.toString()}, 'getSingleProduct');
    if(response != null)
      setState(() {
        detail = response['result']['data'];
      });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPDetail();
  }
  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    if(detail == null || detail.length == 0)
      return Scaffold(body: Center(child: CircularProgressIndicator(),),);
    else return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CachedNetworkImage(
              width: 40,
              imageUrl:  Const.SITE_URL + '/images/' + detail['gallery'][0],
              placeholder: (context, url) => Image(
                image: AssetImage('assets/images/placeholder-image.png'),
                fit: BoxFit.cover,
              ),
              fit: BoxFit.cover,
              //errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('دیدگاه شما',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 150,
                  child: Text('${detail['fa_name']}',style: TextStyle(fontSize: 12),overflow: TextOverflow.ellipsis,),
                )
              ],
            )
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
              decoration: BoxDecoration( color: Colors.white,),
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: ListView(
                //alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Text('دیدگاه خود را شرح دهید',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 10,),
                          Align(
                            child: Text('عنوان نظر',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
                            alignment: Alignment.topRight,
                          ),
                          SizedBox(height: 7,),
                          InputFieldArea(
                              controller: titleController,
                              obscure: false,
                              // ignore: missing_return
                              validator: (String value) {if(!isLength(value, 2)) {
                                return 'لطفا عنوان نظر را وارد کنید';
                              }}
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('نقاط قوت',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
                              GestureDetector(
                                onTap: (){
                                  if(isLength(trim(advController.text), 2))
                                    setState(() {
                                      adv.add(advController.text);
                                      advController.text = '';
                                    });
                                },
                                child: Icon(Icons.add),
                              )
                            ],
                          ),
                          SizedBox(height: 7,),
                          InputFieldArea(
                              controller: advController,
                              obscure: false,
                          ),
                          SizedBox(height: 10,),
                          Container(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Text(adv[index],style: TextStyle(color: Colors.green,fontSize: 16,fontWeight: FontWeight.w500)),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        adv.removeAt(index);
                                      });
                                    },
                                    child: Icon(Icons.delete,color: Colors.grey,),
                                  ),
                                );
                              },
                              itemCount: adv.length,
                            ),
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('نقاط ضعف',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
                              GestureDetector(
                                onTap: (){
                                  if(isLength(trim(disadvController.text), 2))
                                    setState(() {
                                      disadv.add(disadvController.text);
                                      disadvController.text = '';
                                    });
                                },
                                child: Icon(Icons.add),
                              )
                            ],
                          ),
                          SizedBox(height: 7,),
                          InputFieldArea(
                              controller: disadvController,
                              obscure: false,
                          ),
                          SizedBox(height: 10,),
                          Container(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Text(disadv[index],style: TextStyle(color: Colors.red,fontSize: 16,fontWeight: FontWeight.w500)),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        disadv.removeAt(index);
                                      });
                                    },
                                    child: Icon(Icons.delete,color: Colors.grey,),
                                  ),
                                );
                              },
                              itemCount: disadv.length,
                            ),
                          ),
                          Align(
                            child: Text('متن نظر*',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
                            alignment: Alignment.topRight,
                          ),
                          SizedBox(height: 7,),
                          InputFieldArea(
                              controller: textController,
                              obscure: false,maxLines: 4,
                              // ignore: missing_return
                              validator: (String value) {if(!isLength(value, 3)) {
                                return 'متن نظر نباید کمتر از 3 کاراکتر باشد';
                              }}
                          ),
                          SizedBox(height: 50,)
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
                height: 40,
                padding: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: Const.LayoutColor,
                 // borderRadius: BorderRadius.circular(3),
                ),
                child: FlatButton(
                    onPressed: () async{
                      if(_formKey.currentState.validate()) {
                        //_formKey.currentState.save();
                        storeCommentData();
                        //_formKey.currentState.reset();
                        FocusScope.of(context).unfocus();
                      }
                    },
                    child: Center(child: Text(' ثبت دیدگاه ', style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w400)))
                ),
              )
            ],
          )
        ],
      )

    );
  }

  storeCommentData() async {
    Map response = await AuthService.sendDataToServer({
      "pid": widget.productID.toString(),
      "title": titleController.text,
      "text": textController.text,
      "adv": adv.length > 0 ? adv.join(',') : '',
      "disadv": disadv.length > 0 ? disadv.join(',') : '',
    },'storeCommentData');
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