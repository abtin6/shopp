import 'dart:convert';
import 'package:async_loader/async_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopapp/pages/profile/OrderDetail.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  final int status;

  OrderScreen({Key key, @required this.status}) : super(key: key);
  @override
  State<StatefulWidget> createState() => OrderScreenState();

}
class OrderScreenState extends State<OrderScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AsyncLoaderState> _asyncLoaderState = GlobalKey<AsyncLoaderState>();
  static List<dynamic> orderList = [];

  _getOrders() async{
    Map response = await AuthService.sendDataToServer({'status': widget.status.toString()}, 'getOrderList');
    setState(() {
     orderList = response['result']['data'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  List<Container> CreateListItem() {
    List<Container> list = [];
    for (var i = 0; i < orderList.length; i++) {
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
            padding: EdgeInsets.only(top: 15),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(jsonDecode(orderList[i])['uniqid'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                    Text(NumberFormat("#,###").format(jsonDecode(orderList[i])['price']) + ' تومان',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14),),
                  ]),
                SizedBox(height: 10,),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(jsonDecode(orderList[i])['date'],style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15,color: Colors.grey),),
                    ]),
                SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetail(uniqid: jsonDecode(orderList[i])['uniqid'])));},
                      child: Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 17),
                    ),
                  ]),
                SizedBox(height: 10,),
              ],
            ),
        ),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    var _asyncLoader = new AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await _getOrders(),
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
        renderSuccess: ({data}) => (orderList.length == 0) ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Text('سفارش فعالی در این بخش وجود ندارد')],
          )) : Container(
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: Colors.grey[200]),
            padding: EdgeInsets.only(left: 10),
            child: ListView(children: CreateListItem())
        )
    );
    return Container(child: _asyncLoader,);
  }
}