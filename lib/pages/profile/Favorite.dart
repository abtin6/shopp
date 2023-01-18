import 'dart:convert';

import 'package:async_loader/async_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopapp/pages/product/Index.dart';
import 'package:shopapp/services/authenticate.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FavoriteScreenState();

}
class FavoriteScreenState extends State<FavoriteScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AsyncLoaderState> _asyncLoaderState = GlobalKey<AsyncLoaderState>();
  static List<dynamic> favList = [];

  _getFavorites() async{
    Map response = await AuthService.sendDataToServer({}, 'getFavList');
    setState(() {
      favList = response['result']['data'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  List<Container> CreateListItem() {
    List<Container> list = [];
    for (var i = 0; i < favList.length; i++) {
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
            child: GestureDetector(
              onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => ProductScreen(productID: jsonDecode(favList[i])['pid'])));},
              child: Column(
                children: <Widget>[
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CachedNetworkImage(
                          height: 80,
                          imageUrl: jsonDecode(favList[i])['image'],
                          placeholder: (context, url) => Image(
                            width: 80, height: 100,
                            image: AssetImage('assets/images/placeholder-image.png'),
                            fit: BoxFit.cover,
                          ),
                          fit: BoxFit.cover,
                          //errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 160,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(jsonDecode(favList[i])['title'],style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15),),
                          ),
                        ),

                      ]),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      textDirection: TextDirection.ltr,
                      children: [
                        GestureDetector(
                          onTap: () { removeFavItem(i, jsonDecode(favList[i])['pid']); },
                          child: Icon(Icons.delete_sweep),
                        ),
                        Text(jsonDecode(favList[i])['price'].toString() + ' تومان',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14),),
                      ]),
                ],
              ),
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
        initState: () async => await _getFavorites(),
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
        renderSuccess: ({data}) => (favList.length == 0) ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('موردی برای نمایش وجود ندارد!')
            ],
          ),
        ) : Container(
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
        title: Text('علاقه مندی ها'),
        leading: GestureDetector(onTap: (){ Navigator.pop(context); },child: Icon(Icons.arrow_back,color:  Color(0xFF424750))),
      ),
      body: _asyncLoader,
    );
  }

  void removeFavItem(i, productID) async{
    Map response = await AuthService.sendDataToServer({"pid": "${productID}"}, 'delFromFav');
    if(response == null) { // Connection Failed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }else if(response['status']) {
      setState(() {
        favList.removeAt(i);
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('از لیست علاقه مندی ها حذف شد',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
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