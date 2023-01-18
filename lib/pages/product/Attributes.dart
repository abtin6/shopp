import 'package:flutter/material.dart';
import 'package:shopapp/services/authenticate.dart';

class AttrScreen extends StatefulWidget {
  final attr;

  AttrScreen({Key key, @required this.attr}) : super(key: key);
  @override
  State<StatefulWidget> createState() => AttrScreenState();

}
class AttrScreenState extends State<AttrScreen> {

  List<Padding> CreateListItem() {
    List<Padding> list = new List<Padding>();
    for (var i = 0; i < widget.attr.length; i++) {
      list.add(Padding(
        padding: EdgeInsets.only(top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.attr[i]['title'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
            Column(crossAxisAlignment: CrossAxisAlignment.start,children: CreateListsubItem(widget.attr[i]['content']),)
          ],
        ),
      ));
    }
    return list;
  }
  List<Padding> CreateListsubItem(content) {
    List<Padding> list2 = new List<Padding>();
    for (var i = 0; i < content.length; i++) {
      list2.add(Padding(
        padding: EdgeInsets.only(top: 15),
        child: Row(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 120,
              child: Text(content[i]['name'],style: TextStyle(fontWeight: FontWeight.w500),),
            ),
            SizedBox(
              width: 250,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: CreateListsubItemVal(content[i]['value']),),
            ),

          ],
        ),
      ));
    }
    return list2;
  }
  List<Padding> CreateListsubItemVal(content) {
    List<Padding> list3 = new List<Padding>();
    for (var i = 0; i < content.length; i++) {
      list3.add(Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text(content[i].toString()),
      ));
    }
    list3.add(Padding(padding: EdgeInsets.only(),child: Divider(thickness: 1,),));
    return list3;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // widget.attr[0]['title']
    // widget.attr[0]['content'][0]
    // widget.attr[0]['content'][0]['name']
    // widget.attr[0]['content'][0]['value']
    // widget.attr[0]['content'][0]['value'][0]
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('مشخصات فنی',style: TextStyle(fontSize: 16),),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
          color: Colors.white,
          child: ListView(
            children: CreateListItem(),
          ),
        ),
      );
  }

}