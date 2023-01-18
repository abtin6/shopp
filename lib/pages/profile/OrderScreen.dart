import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopapp/components/InputField.dart';
import 'package:shopapp/pages/profile/AccountCodeVerify.dart';
import 'package:shopapp/services/authenticate.dart';

import 'OrdersList.dart';

class OrderListScreen extends StatefulWidget {
  final int index;

  OrderListScreen({Key key, @required this.index}) : super(key: key);

  @override
  State<StatefulWidget> createState() => OrderListScreenState();

}
class OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin{
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(initialIndex: widget.index,length: 5, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[ SliverAppBar(
            title: Text('سفارش های من'),
            pinned: true,
            floating: true,
            bottom: TabBar(
                controller: tabController,
                indicatorColor: Colors.black54,
                isScrollable: true,
                tabs: <Widget>[
                  Tab( text: 'در انتظار پرداخت'),
                  Tab( text: 'درحال پردازش'),
                  Tab( text: 'تحویل شده'),
                  Tab( text: 'لغو شده'),
                  Tab( text: 'مرجوع شده'),
                ]
            ),
            elevation: 5,
          ) ];
        },
        body: Container(
          child: TabBarView(
              controller: tabController,
              children: <Widget>[
                OrderScreen(status: 10),OrderScreen(status: 1),OrderScreen(status: 6),OrderScreen(status: 0),OrderScreen(status: 8)
              ]
          ),
        ) ,
      ),
    );
  }
}