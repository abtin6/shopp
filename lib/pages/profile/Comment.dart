import 'dart:convert';

import 'package:async_loader/async_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopapp/pages/product/Index.dart';
import 'package:shopapp/services/authenticate.dart';

class CommentScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CommentScreenState();

}
class CommentScreenState extends State<CommentScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AsyncLoaderState> _asyncLoaderState = GlobalKey<AsyncLoaderState>();
  static List<dynamic> commentList = [];
  Widget status;

  _getComments() async{
    Map response = await AuthService.sendDataToServer({}, 'getUserComments');
    setState(() {
      commentList = response['result']['data'];
    });
    //print(jsonDecode(favList[0])['title']);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  List<Container> CreateListItem() {
    List<Container> list = [];
    for (var i = 0; i < commentList.length; i++) {
      if((jsonDecode(commentList[i])['status'].toString() == '1'))
        status = Text(' تایید شده ',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,backgroundColor: Colors.lightGreen,color: Colors.white),);
      else
        status = Text(' در انتظار تایید ',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,backgroundColor: Colors.orangeAccent,color: Colors.white),);

      list.add(Container(
        margin: EdgeInsets.only(right: 10,bottom: 10,top: 10),
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
              GestureDetector(
                onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => ProductScreen(productID: jsonDecode(commentList[i])['pid'])));},
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        height: 80,
                        imageUrl: jsonDecode(commentList[i])['image'],
                        placeholder: (context, url) => Image(
                          width: 80, height: 100,
                          image: AssetImage('assets/images/placeholder-image.png'),
                          fit: BoxFit.cover,
                        ),
                        fit: BoxFit.cover,
                        //errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 200,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(jsonDecode(commentList[i])['title'],style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15),),
                              Text(jsonDecode(commentList[i])['product_title'],style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15),),
                            ],
                          )
                        ),
                      ),
                      status
                    ]),
              ),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  textDirection: TextDirection.ltr,
                  children: [
                    GestureDetector(
                      onTap: () { removeCMItem(i, jsonDecode(commentList[i])['id']); },
                      child: Icon(Icons.delete_sweep),
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
        initState: () async => await _getComments(),
        renderLoad: () => Center(child: CircularProgressIndicator(),),
        renderError: ([error]) => Center(child: Text('خطا در اتصال به سرور')),
        renderSuccess: ({data}) => (commentList.length == 0) ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('تا به حال نظری ثبت نکرده اید!')
            ],
          ),
        ) : Container(
            width: page.width,
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                color: Colors.grey[200]
            ),
            padding: EdgeInsets.only(left: 10),
            child: ListView(
                children: CreateListItem()
            )
        )
    );
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('نقد و نظرات ثبت شده'),
        leading: GestureDetector(onTap: (){ Navigator.pop(context); },child: Icon(Icons.arrow_back,color:  Color(0xFF424750))),
      ),
      body: _asyncLoader,
    );
  }

  void removeCMItem(i, CommentID) async{
    Map response = await AuthService.sendDataToServer({"cid": "${CommentID}"}, 'delComment');
    if(response == null) { // Connection Failed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }else if(response['status']) {
      setState(() {
        commentList.removeAt(i);
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('از لیست نظرات حذف شد',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
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