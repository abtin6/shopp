import 'dart:convert';

import 'package:async_loader/async_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/components/InputField.dart';
import 'package:shopapp/pages/profile/OrderScreen.dart';
import 'package:shopapp/pages/profile/OrdersList.dart';
import 'package:shopapp/pages/profile/profile.dart';
import 'package:shopapp/pages/shipping/cart.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/sanitizers.dart';
import 'package:validators/validators.dart';
import 'package:shopapp/constants.dart' as Const;
import 'package:intl/intl.dart' as intl;
import 'package:encrypt/encrypt.dart' as encrypt;

class PaymentScreen extends StatefulWidget {
  final int shipmentID;
  final int shipmentPrice;

  PaymentScreen({Key key, @required this.shipmentID, @required this.shipmentPrice}) : super(key: key);
  @override
  State<StatefulWidget> createState() => PaymentScreenState();

}
class PaymentScreenState extends State<PaymentScreen> {
  static List<dynamic> items = [];
  static List<dynamic> gateways = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AsyncLoaderState> _asyncLoaderState = GlobalKey<AsyncLoaderState>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController advController = new TextEditingController();
  int profit = 0;
  int totalPrice = 0;
  int _selectedVar = 0;
  num discountPrice = 0;

  final key = encrypt.Key.fromUtf8('uxGveJSHSPyIPq49');
  final iv = encrypt.IV.fromUtf8('kfMgf0dvX6D9zwiK');
  var data;
  
  _getCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map response = await AuthService.sendDataToServer({'cname': prefs.getInt('user.cname').toString()}, 'getCartItems');
    if(response != null){
      setState(() {
        items = response['result']['data'];
        if(items.length > 0) {
          for(int i=0; i < items.length; i++) profit += items[i]['profit'];
          for(int i=0; i < items.length; i++) totalPrice += items[i]['offprice'] * items[i]['count'];
          totalPrice = totalPrice + widget.shipmentPrice;
        }
      });
    }
  }
  _getGateways() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map response = await AuthService.sendDataToServer({}, 'getPayGateways');
    if(response != null){
      setState(() {
        gateways = response['result']['data'];
      });
    }
  }
  List<RadioListTile> CreatePayItem() {
    List<RadioListTile> varlist = []; // incs widget
    for (var i = 0; i < gateways.length; i++) {
      if(gateways[i]['default'] == 1 && _selectedVar == 0) _selectedVar = gateways[i]['id'];
      varlist.add(RadioListTile(
          groupValue: (gateways[i]['default'] == 1 && _selectedVar == 0) ? gateways[i]['id'] : _selectedVar,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left:5,bottom: 10),
                child: CachedNetworkImage(
                  height: 50,
                  imageUrl: Const.SITE_URL + '/images/'+ gateways[i]['pic'],
                  placeholder: (context, url) => Image(
                    width: 80,
                    image: AssetImage('assets/images/placeholder-image.png'),
                    fit: BoxFit.cover,
                  ),
                  fit: BoxFit.cover,
                  //errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              Text(gateways[i]['name'],style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey),),
            ],
          ),
          value: gateways[i]['id'],
          onChanged: (val) {setState(() {
            _selectedVar = val;
          });}
      ));

    }
    return varlist;
  }
  Color hexToColor(String hexString, {String alphaChannel = 'FF'}) {
    return Color(int.parse(hexString.replaceFirst('#', '0x$alphaChannel')));
  }

  @override
  void initState() {
    // TODO: implement initState
  super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var _asyncLoader = new AsyncLoader(
        key: _asyncLoaderState,
        initState: () async {
          await _getCartItems();
          await _getGateways();
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
        renderSuccess: ({data}) => Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[200]
              ),
              child: ListView(
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                    margin: EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(width: 1.0, color: Colors.black12),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text('شیوه پرداخت',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                        SizedBox(height: 15),
                        Column(children: CreatePayItem()),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(width: 1.0, color: Colors.black12),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('جزئیات پرداخت',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                            Text('${items.length} کالا',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey),),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('مبلغ کل کالاها',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey),),
                            Text(intl.NumberFormat("#,###").format(totalPrice + profit) + ' تومان ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('هزینه ارسال',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey),),
                            Text((widget.shipmentPrice == 0) ? 'رایگان' : intl.NumberFormat("#,###").format(widget.shipmentPrice) + ' تومان ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('سود شما از خرید',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey),),
                            Text(intl.NumberFormat("#,###").format(profit) + ' تومان ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.red),),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Divider(thickness: 1,),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('جمع',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey),),
                            Text(intl.NumberFormat("#,###").format(totalPrice) + ' تومان ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(width: 1.0, color: Colors.black12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('کد تخفیف',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                    GestureDetector(
                                      onTap: (){
                                        if(isLength(trim(advController.text), 2))
                                          applyDiscount(advController.text);
                                      },
                                      child: Icon(Icons.add),
                                    )
                                  ],
                                ),
                                SizedBox(height: 7),
                                InputFieldArea(
                                  controller: advController,
                                  obscure: false,
                                ),
                                SizedBox(height: 10),
                                if(discountPrice > 0) Container(
                                  child: ListTile(
                                    leading: Text(advController.text,style: TextStyle(color: Colors.green,fontSize: 16,fontWeight: FontWeight.w500)),
                                    trailing: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          advController.text = '';
                                          totalPrice = totalPrice + discountPrice;
                                          discountPrice = 0;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('می توانید کد تخفیف دیگری ثبت کنید',style: TextStyle(fontFamily: 'Vazir',fontSize: 17,fontWeight: FontWeight.bold),),
                                              backgroundColor: Colors.lightBlue,
                                            )
                                        );
                                      },
                                      child: Icon(Icons.delete,color: Colors.grey,),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 70),
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                    width: double.infinity,
                    height: 70,
                    padding: EdgeInsets.only(right: 10,left: 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            top: BorderSide(color: Colors.grey[300])
                        )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FlatButton(
                          onPressed: () async{
                            var userInfo = await AuthService.getUserInfo();
                            if(userInfo == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('ابتدا وارد حساب کاربری خود شوید',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
                                    backgroundColor: Colors.orange,
                                  )
                              );
                              // error
                            }else if(_selectedVar == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('شیوه پرداخت را انتخاب کنید',style: TextStyle(fontFamily: 'Vazir',fontSize: 17,fontWeight: FontWeight.bold),),
                                    backgroundColor: Colors.lightBlue,
                                  )
                              );
                            }else {
                              var ApiToken = await AuthService.getApiToken();
                              if(ApiToken == null || ApiToken == 'False') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('ابتدا وارد حساب کاربری خود شوید',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
                                      backgroundColor: Colors.orange,
                                    )
                                );
                                // error
                              }else {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                Map queryString = {
                                  'bank_id': _selectedVar.toString(),
                                  'totalprice': totalPrice.toString(),
                                  'discount': discountPrice.toString(),
                                  'shipment_id': widget.shipmentID.toString(),
                                  'shipment_price': widget.shipmentPrice.toString(),
                                  'cname': prefs.getInt('user.cname').toString(),
                                };
                                if(_selectedVar == 3) { // is COD
                                  codPayment(queryString);
                                }else {
                                  final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
                                  data = encrypter.encrypt(jsonEncode(queryString), iv: iv).base64;
                                  var url = Const.API_URL + '/payment?api_token=${ApiToken}&data=${data}';
                                  await launch(url);
                                }
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Const.LayoutColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            width: 150,height: 45,
                            padding: EdgeInsets.only(top: 8.5,right: 50),
                            child: Text('پرداخت',style: TextStyle(color:Colors.white,fontSize: 18,fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Text(intl.NumberFormat("#,###").format(totalPrice) + ' تومان ',style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),),
                      ],
                    )
                ),
              ],
            )
          ],
        )
    );
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('روش پرداخت',style: TextStyle(fontSize: 18),),
      ),
      body: _asyncLoader,
    );
  }
  void applyDiscount(code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map response = await AuthService.sendDataToServer({'code': code, 'cname': prefs.getInt('user.cname').toString()}, 'applyDiscount');
    if(response == null) { // Connection Failed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }else if(response['status']) {
      var discount = response['result']['data']['discount'];
      if(discountPrice == 0) {
        setState(() {
          if(discount['discount'] < 100)
            discountPrice = (totalPrice * (discount['discount'] /100) ).round();
          else
            discountPrice = discount['discount'];

          totalPrice = totalPrice - discountPrice;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(intl.NumberFormat("#,###").format(discountPrice) + ' تومان تخفیف از مبلغ قابل پرداخت کسر شد',style: TextStyle(fontFamily: 'Vazir',fontSize: 17,fontWeight: FontWeight.bold),),
              backgroundColor: Colors.green,
            )
        );
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text( 'شما یک کد تخفیف فعال دارید',style: TextStyle(fontFamily: 'Vazir',fontSize: 17,fontWeight: FontWeight.bold),),
              backgroundColor: Colors.blue,
            )
        );
      }

    }else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['result']['message'],style: TextStyle(fontFamily: 'Vazir',fontSize: 17,fontWeight: FontWeight.bold),),
            backgroundColor: Colors.red,
          )
      );
    }
  }

  void codPayment(data) async {
    Map response = await AuthService.sendDataToServer(data, 'codPayment');
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
            content: Text('سفارش شما با موفقیت دریافت شد',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.green,
          )
      );
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrderListScreen(index: 1)));
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['result']['message'],style: TextStyle(fontFamily: 'Vazir',fontSize: 17,fontWeight: FontWeight.bold),),
            backgroundColor: Colors.red,
          )
      );
    }
  }

}