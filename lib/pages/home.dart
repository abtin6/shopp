import 'dart:convert';
import 'dart:math';

import 'package:async_loader/async_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/pages/brandProducts.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:shopapp/constants.dart' as Const;
import 'package:url_launcher/url_launcher.dart';

import 'incProducts.dart';
import 'product/Index.dart';
import 'categoryProducts.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}
class HomePageState extends State<HomePage> {

  static List<dynamic> imgList = [];
  static List<dynamic> catList = [];
  static List<dynamic> incList = [];
  static List<dynamic> incImgList = [];
  static List<dynamic> mostSoldList = [];
  static List<dynamic> newestList = [];
  static List<dynamic> brandList = [];
  static List<dynamic> mvisitedList = [];
  static List<dynamic> catPList = [];
  final GlobalKey<AsyncLoaderState> _asyncLoaderState = GlobalKey<AsyncLoaderState>();
  Widget slider;

  _getCatProducts() async {
    Map response = await AuthService.sendDataToServer({}, 'getSPCatProducts');
    if(response != null)
      setState(() {
        catPList = response['result']['data'];
      });
  }
  _getMostVisited() async {
    Map response = await AuthService.sendDataToServer({}, 'getMostVisited');
    if(response != null)
      setState(() {
        mvisitedList = response['result']['data'];
      });
  }
  _getBrands() async {
    Map response = await AuthService.sendDataToServer({}, 'getSpecialBrands');
    if(response != null)
      setState(() {
        brandList = response['result']['data'];
      });
  }
  _getNewestSold() async {
    Map response = await AuthService.sendDataToServer({}, 'getNewestSold');
    if(response != null)
      setState(() {
        newestList = response['result']['data'];
      });
  }
  _getMostSold() async {
    Map response = await AuthService.sendDataToServer({}, 'getMostSold');
    if(response != null)
      setState(() {
        mostSoldList = response['result']['data'];
      });
  }
  _getIncs() async {
    Map response = await AuthService.sendDataToServer({}, 'getIncredibles');
    if(response != null)
      setState(() {
        incList = response['result']['data'];
      });
  }
  _getIncImgs() async {
    Map response = await AuthService.sendDataToServer({}, 'getIncImages');
    if(response != null)
      setState(() {
        incImgList = response['result']['data'];
      });
  }

  List<Container> CreateListItem() {
    List<Container> list = []; // incs widget
    for (var i = 0; i < incList.length; i++) {
      list.add(Container(
        width: 150, height: 260,
        margin: EdgeInsets.only(left: 10),
        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
        child: GestureDetector(
          onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => ProductScreen(productID: incList[i]['id'])));},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CachedNetworkImage(
                width: 80,
                imageUrl: incList[i]['image'],
                placeholder: (context, url) => Image(
                  image: AssetImage('assets/images/placeholder-image.png'),
                  fit: BoxFit.cover,
                ),
                fit: BoxFit.cover,
                //errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              SizedBox(height: 10),
              Text(incList[i]['name'], style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 33, height: 21,
                    child: Text(' ' + incList[i]['discount'].toString() + '% ', style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.white),),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Const.LayoutColor,
                    ),
                  ),
                  Text(intl.NumberFormat("#,###").format(incList[i]['offprice']) + 'تومان',style: TextStyle(fontWeight: FontWeight.w500),)
                ],
              ),
              /*Align(
                alignment: Alignment.centerLeft,
                child: Text(intl.NumberFormat("#,###").format(incList[i]['price']),style: TextStyle(decoration: TextDecoration.lineThrough),),
              ),*/
              (incList[i]['time'] > DateTime.now().millisecondsSinceEpoch / 1000 ) ? CountdownTimer(
                endTime: incList[i]['time'] * 1000,
                widgetBuilder: (_, CurrentRemainingTime time) {
                  if (time == null) {
                    return Text('اتمام پیشنهاد');
                  }
                  return Text('${time.days} روز ${time.hours}:${time.min}:${time.sec}',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Vazir'),);
                },
              ) : Row(children: <Widget>[Icon(Icons.timer,size: 16,),Text('اتمام پیشنهاد')],),
            ],
          ),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          //boxShadow: [BoxShadow(color: Colors.green, spreadRadius: 3),],
        ),
      ));
    }
    //if(incList.length > 10) list.add();
    return list;
  }

  _getCats() async{
    Map response = await AuthService.sendDataToServer({}, 'get4Cat');
    if(response != null)
      setState(() {
        catList = response['result']['data'];
      });
    //print(jsonDecode(favList[0])['title']);
  }
  _getSliderImg() async{
    Map response = await AuthService.sendDataToServer({},'getSlider');
    //var list = response['result']['data'];
    if(response != null) {
      setState(() {
        imgList = response['result']['data'];
      });
      slider = Expanded(
          child: CarouselSlider(
            options: CarouselOptions(),
            items: imgList.map((item) => GestureDetector(
              onTap: () async{
                /*if (await canLaunch(item['url'])) */await launch(item['url']);
                //else throw 'Could not launch ${item['url']}';
              },
              child: Container(
                margin: EdgeInsets.only(right: 5,left: 5,top: 15),
                child: CachedNetworkImage(
                  imageUrl: item['image'],
                  placeholder: (context, url) => Image(
                    image: AssetImage('assets/images/placeholder-image.png'),
                    fit: BoxFit.cover,
                  ),
                  fit: BoxFit.cover,
                  //errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            )).toList(),
          )
      );
    }

    //list.forEach((item) => imgList.add(item));
  }

  setCookie(cname) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('user.cname')) await prefs.setInt('user.cname', cname);
  }

  @override
  void initState() {
    // TODO: implement initState
    setCookie(DateTime.now().millisecondsSinceEpoch);
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    var page = MediaQuery.of(context).size;
    var _asyncLoader = new AsyncLoader(
        key: _asyncLoaderState,
        initState: () async {
          await _getSliderImg();
          await _getCats();
          await _getIncs();
          await _getBrands();
          await _getMostVisited();
          await _getCatProducts();
          await _getIncImgs();
          await _getMostSold();
          await _getNewestSold();
        },
        renderLoad: () => Center(child: CircularProgressIndicator(),),
        renderError: ([error]) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontSize: 16),),
                FlatButton(
                    color: Colors.red,
                    child: Text("تلاش دوباره", style: TextStyle(color: Colors.white),),
                    onPressed: () => _asyncLoaderState.currentState.reloadState())
              ],
            )),
        renderSuccess: ({data}) => ListView(
          children: <Widget>[
            Row(children: <Widget>[slider],),
            Container(
                height: 120,width: page.width,
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(width: 13);
                  },
                  //shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => CategoryProductListScreen(cat: jsonDecode(catList[index]),)));},
                      child: Column(
                        children: <Widget>[
                          CircleAvatar(
                            //backgroundColor: Colors.lightGreen,
                            radius: 25,
                            child: ClipOval(
                              child: (jsonDecode(catList[index])['image']) == '' ? Image.asset('assets/images/tagico.png')
                                  : CachedNetworkImage(
                                width: 64,
                                imageUrl: jsonDecode(catList[index])['image'],
                                fit: BoxFit.cover,
                                //errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                          ),
                          Text(jsonDecode(catList[index])['title'],style: TextStyle(fontSize: 13,fontWeight: FontWeight.w300),)
                        ],
                      ),
                    );
                  },
                  itemCount: catList.length,
                )
            ),
            if(incList.length > 0) Container(
              color: Const.LayoutColor,
              height: 300,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CachedNetworkImage(
                          width: 120,
                          imageUrl: Const.SITE_URL + '/images/d9b15d68.png',
                          fit: BoxFit.cover,
                          //errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                        if(incList.length > 10) GestureDetector(
                          child: Text('مشاهده همه >',style: TextStyle(color: Colors.white),),
                          onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => IncProductListScreen()));},
                        )
                      ],
                    ),
                    Row(children: CreateListItem()),
                    if(incList.length > 10) Container(
                      width: 150,height: 50,
                      margin: EdgeInsets.only(left: 10),
                      padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.arrow_forward,color: Const.LayoutColor),
                          GestureDetector(
                              onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => IncProductListScreen()));},
                              child: Text('مشاهده همه', style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        //boxShadow: [BoxShadow(color: Colors.green, spreadRadius: 3),],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            /* Incredible IMAGES */
            Container(
              child: Table(children: [
                TableRow(children: [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: GestureDetector(
                      onTap: () async{
                        /*if (await canLaunch(incImgList[0]['url'])) */await launch(incImgList[0]['url']);
                        //else throw 'Could not launch ${incImgList[0]['url']}';
                      },
                      child: CachedNetworkImage(
                        width: 80,
                        imageUrl: incImgList[0]['image'],
                        placeholder: (context, url) => Image(
                          image: AssetImage('assets/images/placeholder-image.png'),
                          fit: BoxFit.cover,
                        ),
                        fit: BoxFit.cover,
                        //errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: GestureDetector(
                      onTap: () async{
                        /*if (await canLaunch(incImgList[1]['url'])) */await launch(incImgList[1]['url']);
                        //else throw 'Could not launch ${incImgList[1]['url']}';
                      },
                      child: CachedNetworkImage(
                        width: 80,
                        imageUrl: incImgList[1]['image'],
                        placeholder: (context, url) => Image(
                          image: AssetImage('assets/images/placeholder-image.png'),
                          fit: BoxFit.cover,
                        ),
                        fit: BoxFit.cover,
                        //errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ]),
                TableRow(children: [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: GestureDetector(
                      onTap: () async{
                        /*if (await canLaunch(incImgList[2]['url'])) */await launch(incImgList[2]['url']);
                        //else throw 'Could not launch ${incImgList[2]['url']}';
                      },
                      child: CachedNetworkImage(
                        width: 80,
                        imageUrl: incImgList[2]['image'],
                        placeholder: (context, url) => Image(
                          image: AssetImage('assets/images/placeholder-image.png'),
                          fit: BoxFit.cover,
                        ),
                        fit: BoxFit.cover,
                        //errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: GestureDetector(
                      onTap: () async{
                        /*if (await canLaunch(incImgList[3]['url'])) */await launch(incImgList[3]['url']);
                        //else throw 'Could not launch ${incImgList[3]['url']}';
                      },
                      child: CachedNetworkImage(
                        width: 80,
                        imageUrl: incImgList[3]['image'],
                        placeholder: (context, url) => Image(
                          image: AssetImage('assets/images/placeholder-image.png'),
                          fit: BoxFit.cover,
                        ),
                        fit: BoxFit.cover,
                        //errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ])
              ],
              ),
            ),
            if(mostSoldList.length > 0) Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 15,bottom: 12),
                  child: Text('پرفروش ترین کالاها',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                ),
                Container(
                  height: 180,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 150,height: 200,
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            border: Border.all(
                                width: 1.0, color: Colors.black12
                            ),
                            //boxShadow: [BoxShadow(color: Colors.green, spreadRadius: 3),],
                          ),
                          child: GestureDetector(
                            onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => ProductScreen(productID: mostSoldList[index]['id'])));},
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                CachedNetworkImage(
                                  height: 100,
                                  imageUrl: mostSoldList[index]['image'],
                                  placeholder: (context, url) => Image(
                                    width: 80,
                                    image: AssetImage('assets/images/placeholder-image.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  fit: BoxFit.cover,
                                  //errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                                Text('${mostSoldList[index]['name']}',style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: mostSoldList.length
                  ),
                ),
              ],
            ),
            /* Incredible IMAGE */
            Padding(
              padding: EdgeInsets.all(15),
              child: GestureDetector(
                onTap: () async{
                  /*if (await canLaunch(incImgList[4]['url'])) */await launch(incImgList[4]['url']);
                  //else throw 'Could not launch ${incImgList[4]['url']}';
                },
                child: CachedNetworkImage(
                  height: 70,
                  imageUrl: incImgList[4]['image'],
                  placeholder: (context, url) => Image(
                    image: AssetImage('assets/images/placeholder-image.png'),
                    fit: BoxFit.cover,
                  ),
                  fit: BoxFit.cover,
                  //errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            /* NEWEST Products */
            Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 15,bottom: 8,top: 18),
                  child: Text('جدیدترین کالاها',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                ),
                Container(
                  height: 240,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 150,height: 200,
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            border: Border.all(
                                width: 1.0, color: Colors.black12
                            ),
                            //boxShadow: [BoxShadow(color: Colors.green, spreadRadius: 3),],
                          ),
                          child: GestureDetector(
                            onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => ProductScreen(productID: newestList[index]['id'])));},
                            child: (newestList[index]['discount'] > 0) ? Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                CachedNetworkImage(
                                  height: 100,
                                  imageUrl: newestList[index]['image'],
                                  placeholder: (context, url) => Image(
                                    width: 80,
                                    image: AssetImage('assets/images/placeholder-image.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  fit: BoxFit.cover,
                                  //errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                                Text(newestList[index]['name'],style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500)),
                                if(newestList[index]['quantity'] == 0) Text('اتمام موجودی',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Colors.red)),
                                if(newestList[index]['quantity'] > 0) Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      width: 33, height: 21,
                                      child: Text(' ' + newestList[index]['discount'].toString() + '% ', style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.white),),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(intl.NumberFormat("#,###").format(newestList[index]['offprice']) + 'تومان',style: TextStyle(fontWeight: FontWeight.w500),)
                                  ],
                                ),
                                if(newestList[index]['quantity'] > 0) Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(intl.NumberFormat("#,###").format(newestList[index]['price']),style: TextStyle(decoration: TextDecoration.lineThrough),),
                                ),
                              ],
                            ) : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                CachedNetworkImage(
                                  height: 100,
                                  imageUrl: newestList[index]['image'],
                                  placeholder: (context, url) => Image(
                                    width: 80,
                                    image: AssetImage('assets/images/placeholder-image.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  fit: BoxFit.cover,
                                  //errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                                Text(newestList[index]['name'],style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500)),
                                if(newestList[index]['quantity'] == 0) Text('اتمام موجودی',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Colors.red)),
                                if(newestList[index]['quantity'] > 0) Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(intl.NumberFormat("#,###").format(newestList[index]['offprice']) + 'تومان',style: TextStyle(fontWeight: FontWeight.w500),)
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: newestList.length
                  ),
                ),
              ],
            ),
            if(brandList.length > 0) Column(
              children: <Widget>[
                Container(
                  height: 140,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 150,height: 180,
                          margin: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                          // padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                          decoration: BoxDecoration(
                            //borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            border: Border(
                              left: BorderSide(width: 1.0, color: Colors.grey[300]),
                            ),
                            //boxShadow: [BoxShadow(color: Colors.green, spreadRadius: 3),],
                          ),
                          child: GestureDetector(
                            onTap: (){Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => BrandProductListScreen(id: brandList[index]['id'])));},
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CachedNetworkImage(
                                  height: 110,
                                  imageUrl: brandList[index]['image'],
                                  placeholder: (context, url) => Image(
                                    width: 80,
                                    image: AssetImage('assets/images/placeholder-image.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  fit: BoxFit.cover,
                                  //errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: brandList.length
                  ),
                ),
              ],
            ),
            if(catPList.length > 0) Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 15,bottom: 8,top: 18),
                  child: Text(catPList[0]['catName'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                ),
                Container(
                  height: 220,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 150,height: 200,
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            border: Border.all(
                                width: 1.0, color: Colors.black12
                            ),
                            //boxShadow: [BoxShadow(color: Colors.green, spreadRadius: 3),],
                          ),
                          child: GestureDetector(
                            onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => ProductScreen(productID: catPList[index]['id'])));},
                            child: (catPList[index]['discount'] > 0) ? Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                CachedNetworkImage(
                                  height: 100,
                                  imageUrl: catPList[index]['image'],
                                  placeholder: (context, url) => Image(
                                    width: 80,
                                    image: AssetImage('assets/images/placeholder-image.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  fit: BoxFit.cover,
                                  //errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                                Text(catPList[index]['name'],style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500)),
                                if(catPList[index]['quantity'] == 0) Text('اتمام موجودی',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Colors.red)),
                                if(catPList[index]['quantity'] > 0) Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      width: 33, height: 21,
                                      child: Text(' ' + catPList[index]['discount'].toString() + '% ', style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.white),),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(intl.NumberFormat("#,###").format(catPList[index]['offprice']) + 'تومان',style: TextStyle(fontWeight: FontWeight.w500),)
                                  ],
                                ),
                                if(catPList[index]['quantity'] > 0) Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(intl.NumberFormat("#,###").format(catPList[index]['price']) + 'تومان',style: TextStyle(decoration: TextDecoration.lineThrough),),
                                ),
                              ],
                            ) : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                CachedNetworkImage(
                                  height: 100,
                                  imageUrl: catPList[index]['image'],
                                  placeholder: (context, url) => Image(
                                    width: 80,
                                    image: AssetImage('assets/images/placeholder-image.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  fit: BoxFit.cover,
                                  //errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                                Text(catPList[index]['name'],style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500)),
                                if(catPList[index]['quantity'] == 0) Text('اتمام موجودی',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Colors.red)),
                                if(catPList[index]['quantity'] > 0) Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(intl.NumberFormat("#,###").format(catPList[index]['offprice']) + 'تومان',style: TextStyle(fontWeight: FontWeight.w500),)
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: catPList.length
                  ),
                ),
              ],
            ),
            /* MOST VISITED */
            Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 15,bottom: 8,top: 18),
                  child: Text('محصولات پربازدید اخیر',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                ),
                Container(
                  height: 220,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 150,height: 200,
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            border: Border.all(
                                width: 1.0, color: Colors.black12
                            ),
                            //boxShadow: [BoxShadow(color: Colors.green, spreadRadius: 3),],
                          ),
                          child: GestureDetector(
                            onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => ProductScreen(productID: mvisitedList[index]['id'])));},
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                CachedNetworkImage(
                                  height: 100,
                                  imageUrl: mvisitedList[index]['image'],
                                  placeholder: (context, url) => Image(
                                    width: 80,
                                    image: AssetImage('assets/images/placeholder-image.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  fit: BoxFit.cover,
                                  //errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                                Text('${mvisitedList[index]['name']}',style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500)),
                                Text('${mvisitedList[index]['view']} بازدید',style: TextStyle(fontSize: 13,color: Colors.grey))
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: mvisitedList.length
                  ),
                ),
              ],
            ),

          ],
        ),
    );
    return RefreshIndicator(
      onRefresh: () => _handleRefresh(),
      child: Container(
        margin: const EdgeInsets.only(top: 5,bottom: 2),
        child: _asyncLoader ,
      ),
    );
  }

  Future<Null> _handleRefresh() async {
    _asyncLoaderState.currentState.reloadState();
    return null;
  }


}