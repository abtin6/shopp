import 'dart:async';
import 'dart:convert';

import 'package:async_loader/async_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopapp/components/InputField.dart';
import 'package:shopapp/pages/profile/AccountCodeVerify.dart';
import 'package:shopapp/services/authenticate.dart';

class OrderDetail extends StatefulWidget {
  final String uniqid;

  OrderDetail({Key key, @required this.uniqid}) : super(key: key);
  @override
  State<StatefulWidget> createState() => OrderDetailState();

}
class OrderDetailState extends State<OrderDetail> {
  static Map<String, dynamic> Order;
  static List<dynamic> productList = [];
  final GlobalKey<AsyncLoaderState> _asyncLoaderState = GlobalKey<AsyncLoaderState>();


  _getOrder() async{
    Map response = await AuthService.sendDataToServer({'uniqid': widget.uniqid}, 'getOrderDetail');
    setState(() {
      Order = jsonDecode(response['result']['data']);
      productList = Order['products'];
    });
    //print(jsonDecode(favList[0])['title']);
  }
  List<Padding> CreateListItem() {
    List<Padding> list = new List<Padding>();
    for (var i = 0; i < productList.length; i++) {
      list.add(Padding(
        padding: EdgeInsets.only(top: 15),
        child: Column(
          children: <Widget>[
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                    width: 80, height: 100,
                    imageUrl: productList[i]['image'],
                    placeholder: (context, url) => Image(
                      width: 80, height: 100,
                      image: AssetImage('assets/images/placeholder-image.png'),
                      fit: BoxFit.cover,
                    ),
                    fit: BoxFit.cover,
                    //errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 100,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: <Widget>[
                          Text(productList[i]['name'],style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15),),
                          Text("${productList[i]['count']} عدد",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15),),
                        ],
                      ),
                    ),
                  ),
                ]),
            Divider(height: 2,thickness: 1,)
          ],
        ),
      ));
    }
    return list;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var page = MediaQuery.of(context).size;
    var _asyncLoader = new AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await _getOrder(),
        renderLoad: () => Center(child: CircularProgressIndicator(),),
        renderError: ([error]) => Center(child: Text('خطا در اتصال به سرور')),
        renderSuccess: ({data}) => Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
            child: Column(
              children: <Widget>[
                Table(
                  border: TableBorder.all(color: Colors.grey[400]),
                  children: [
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: <Widget>[
                            Text('تحویل گیرنده',style: TextStyle(color: Colors.grey,fontSize: 15),),
                            Text(Order['name'],style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: <Widget>[
                            Text('تاریخ ثبت سفارش',style: TextStyle(color: Colors.grey,fontSize: 15),),
                            Text(Order['date'],style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: <Widget>[
                            Text('شماره تلفن',style: TextStyle(color: Colors.grey,fontSize: 15),),
                            Text(Order['tel'].toString(),style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: <Widget>[
                            Text('مبلغ کل',style: TextStyle(color: Colors.grey,fontSize: 15),),
                            Text(NumberFormat("#,###").format(Order['price']),style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: <Widget>[
                            Text('نحوه پرداخت',style: TextStyle(color: Colors.grey,fontSize: 15),),
                            Text(Order['payment'],style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: <Widget>[
                            Text('کد سفارش',style: TextStyle(color: Colors.grey,fontSize: 15),),
                            Text(widget.uniqid,style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      )
                    ]),
                  ],
                ),
                SizedBox(height: 10,),
                Column(
                  children: <Widget>[
                    Text('ارسال به',style: TextStyle(color: Colors.grey,fontSize: 15),),
                    Text(Order['addr'],style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.bold),),
                  ],
                ),
                SizedBox(height: 10,),
                Expanded(
                    child: ListView(
                        children: CreateListItem()
                    )
                ),
              ],
            ),
          ),
        )
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('جزئیات سفارش'),
        leading: GestureDetector(onTap: (){ Navigator.pop(context); },child: Icon(Icons.arrow_back,color:  Color(0xFF424750))),
      ),
      body: _asyncLoader,

    );
  }

}