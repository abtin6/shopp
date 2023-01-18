import 'dart:async';
import 'dart:convert';

import 'package:async_loader/async_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopapp/components/InputField.dart';
import 'package:shopapp/pages/profile/AccountCodeVerify.dart';
import 'package:shopapp/pages/profile/AddAddress.dart';
import 'package:shopapp/pages/shipping/cart.dart';
import 'package:shopapp/services/authenticate.dart';

import 'AddressEdit.dart';

class AddressScreen extends StatefulWidget {
  final String back;
  @override
  State<StatefulWidget> createState() => AddressScreenState();
  AddressScreen({Key key, this.back}) : super(key: key);

}
class AddressScreenState extends State<AddressScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AsyncLoaderState> _asyncLoaderState = GlobalKey<AsyncLoaderState>();
  static List<dynamic> AddressList = [];
  Widget status;
  static List<dynamic> provinceList = [];

  _getAddreses() async{
    Map response = await AuthService.sendDataToServer({}, 'getUserAddr');
    setState(() {
      AddressList = response['result']['data'];
    });
    //print(jsonDecode(favList[0])['title']);
  }
  _getProvinces() async{
    Map response = await AuthService.sendDataToServer({}, 'getProvinces');
    provinceList = jsonDecode(response['result']['data']);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  List<Container> CreateListItem() {
    List<Container> list = [];
    for (var i = 0; i < AddressList.length; i++) {
      list.add(Container(
        margin: EdgeInsets.only(right: 10,bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(width: 1.0, color: Colors.black12),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 10,right: 10),
          child: Column(
            children: <Widget>[
              Row(children: <Widget>[Text(jsonDecode(AddressList[i])['addr'],style: TextStyle(fontSize: 17),)]),
              SizedBox(height: 10),
              Row(children: <Widget>[
                Icon(Icons.filter_center_focus,color: Colors.black87,size: 28),
                SizedBox(width: 8),
                Text(provinceList[jsonDecode(AddressList[i])['pid']]['name'])
              ]),
              SizedBox(height: 3),
              Row(children: <Widget>[
                Icon(Icons.email,color: Colors.black87,size: 28),
                SizedBox(width: 8),
                Text(jsonDecode(AddressList[i])['pcode'].toString())
              ]),
              SizedBox(height: 3),
              Row(children: <Widget>[
                Icon(Icons.phone,color: Colors.black87,size: 28),
                SizedBox(width: 8),
                Text(jsonDecode(AddressList[i])['tel'].toString())
              ]),
              SizedBox(height: 3),
              Row(children: <Widget>[
                Icon(Icons.person,color: Colors.black87,size: 28),
                SizedBox(width: 8),
                Text(jsonDecode(AddressList[i])['name'])
              ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => AddressEdit(ID: jsonDecode(AddressList[i])['id'].toString())));},
                      child: Text('ویرایش آدرس >',style: TextStyle(color: Colors.lightBlue,fontWeight: FontWeight.w500),),
                    ),
                    PopupMenuButton<String>(
                        onSelected: (String choice) async{
                          if (!RegExp(r"/remove/").hasMatch(choice)) {
                            choice = choice.replaceAll('remove', '');
                            removeAddrItem(choice);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                                value: 'remove' + jsonDecode(AddressList[i])['id'].toString(),
                                child: Row(
                                    children: <Widget>[
                                      Icon(Icons.delete,color: Colors.red,size: 28),
                                      Text('حذف آدرس')
                                    ]
                                )
                            ),
                          ];
                        }
                    ),
                  ]),
            ],
          ),
        ),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    var page = MediaQuery.of(context).size;
    var _asyncLoader = new AsyncLoader(
        key: _asyncLoaderState,
        initState: () async {
          await _getProvinces();
          await _getAddreses();
        },
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
        renderSuccess: ({data}) => (AddressList.length == 0) ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('تا به حال آدرسی ثبت نکرده اید!')
            ],
          ),
        ) : Expanded(child: Container(
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                color: Colors.grey[200]
            ),
            padding: EdgeInsets.only(left: 10,top: 2),
            width: page.width,
            child: ListView(
                children: CreateListItem()
            )
        ))
    );
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('آدرس ها'),
        leading: GestureDetector(onTap: (){
          if(widget.back == 'cart') Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CartScreen()));
          else Navigator.pop(context);
          }
          ,child: Icon(Icons.arrow_back,color:  Color(0xFF424750))),
      ),
      body: RefreshIndicator(
        onRefresh: () => _handleRefresh(),
        child: Container(
          child: Padding(
            padding: EdgeInsets.only(top: 15),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => AddAddress()));},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Icon(Icons.add_location,color: Colors.black87,size: 28),
                          ),
                          Text('اضافه کردن آدرس جدید',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500),),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 17),
                    ],
                  ),
                ),
                Divider(thickness: 2,),
                _asyncLoader
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<Null> _handleRefresh() async {
    _asyncLoaderState.currentState.reloadState();
    return null;
  }
  void removeAddrItem(addrID) async{
    Map response = await AuthService.sendDataToServer({"id": "${addrID}"}, 'delAddress');
    if(response == null) { // Connection Failed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }else if(response['status']) {
      setState(() {
        AddressList = response['result']['data'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('آدرس موردنظر حذف شد',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.green,
          )
      );
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