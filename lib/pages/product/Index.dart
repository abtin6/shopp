import 'package:async_loader/async_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/pages/brandProducts.dart';
import 'package:shopapp/pages/shipping/cart.dart';
import 'package:shopapp/pages/product/AddQuestion.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shopapp/constants.dart' as Const;
import 'package:validators/validators.dart';
import 'package:share_plus/share_plus.dart';
import 'AddComment.dart';
import 'Attributes.dart';
import 'Comments.dart';
import 'Description.dart';
import 'package:intl/intl.dart' as intl;

import 'Sellers.dart';

class ProductScreen extends StatefulWidget {
  final int productID;

  ProductScreen({Key key, @required this.productID}) : super(key: key);
  @override
  State<StatefulWidget> createState() => ProductScreenState();

}
class ProductScreenState extends State<ProductScreen> {
  Map detail;
  Widget slider;
  int _current = 0;
  int _ccount = 0;
  String _selectedVar = '';
  bool isFavorite = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AsyncLoaderState> _asyncLoaderState = GlobalKey<AsyncLoaderState>();

  Color hexToColor(String hexString, {String alphaChannel = 'FF'}) {
    return Color(int.parse(hexString.replaceFirst('#', '0x$alphaChannel')));
  }

  _getPDetail() async {
    Map response = await AuthService.sendDataToServer({'id': widget.productID.toString()}, 'getSingleProduct');
    if(response != null)
      setState(() {
        detail = response['result']['data'];
        slider = CarouselSlider(
          options: CarouselOptions(
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }
          ),
          items: detail['gallery'].map<Widget>((item) => Container(
            margin: EdgeInsets.only(right: 5,left: 5,top: 15),
            child: CachedNetworkImage(
              imageUrl: Const.SITE_URL + "/images/" + item,
              placeholder: (context, url) => Image(
                image: AssetImage('assets/images/placeholder-image.png'),
                fit: BoxFit.cover,
              ),
              fit: BoxFit.cover,
              //errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          )).toList(),
        );
        isFavorite = detail['isFav'];
      });
  }
  _getCCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map response = await AuthService.sendDataToServer({'cname': prefs.getInt('user.cname').toString() }, 'getCartCount');
    if(response != null)
      setState(() {
        _ccount = response['result']['data']['cartCount'];
      });
  }
  List<Container> CreateAttrItem() {
    List<Container> list = []; // attr widget
    if(detail['attr'] != null){
      for (var i = 0; i < detail['attr'].length; i++) {
        list.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
          child: Row(
            children: <Widget>[
              Text(detail['attr'][i]['name'] + ' : ',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15),),
              Text(detail['attr'][i]['value'],style: TextStyle(fontSize: 15),),
            ],
          ),
        ));
      }
    }
    //if(incList.length > 10) list.add();
    return list;
  }
  List<Container> CreateAdv() {
    List<Container> listAdv = []; // attr widget
    for (var i = 0; i < detail['adv'].length; i++) {
      listAdv.add(Container(
        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
        child: Text(detail['adv'][i],style: TextStyle(fontSize: 15),),
      ));
    }
    //if(incList.length > 10) list.add();
    return listAdv;
  }
  List<Container> CreateDisAdv() {
    List<Container> listDisAdv = []; // attr widget
    for (var i = 0; i < detail['disadv'].length; i++) {
      listDisAdv.add(Container(
        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
        child: Text(detail['disadv'][i],style: TextStyle(fontSize: 15),),
      ));
    }
    //if(incList.length > 10) list.add();
    return listDisAdv;
  }
  List<Container> CreateCommentItem() {
    List<Container> cmlist = []; // incs widget
    for (var i = 0; i < detail['comment'].length; i++) {
      if(i == 5){
        cmlist.add(Container(
          width: 100, height: 200,
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
          child: GestureDetector(
            onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => CMListScreen(productID: detail['id'])));},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.arrow_forward,color: Colors.lightBlueAccent),
                Text('مشاهده همه', style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
              ],
            ),
          ),
        ));
        break;
      }
      cmlist.add(Container(
        width: 220, height: 200,
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
        child: GestureDetector(
          onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => CMListScreen(productID: detail['id'])));},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(detail['comment'][i]['title'], style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis),
              Text(detail['comment'][i]['recommend']['text'], style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: (detail['comment'][i]['recommend']['color'] == 'green') ? Colors.green : Colors.orangeAccent)),
              SizedBox(
                height: 73,
                child: Text(detail['comment'][i]['text'], style: TextStyle(fontSize: 14),overflow: TextOverflow.fade,softWrap: true,),
              ),
              Text(detail['comment'][i]['date'] + ' ~ ' + detail['comment'][i]['name']),
            ],
          ),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 1,
            //offset: Offset(0, 3), // changes position of shadow
          )],
        ),
      ));

    }
    //if(incList.length > 10) list.add();
    return cmlist;
  }
  List<RadioListTile> CreateVarItem() {
    List<RadioListTile> varlist = []; // incs widget
    for (var i = 0; i < detail['varvalue'].length; i++) {
      varlist.add(RadioListTile(
          groupValue: _selectedVar,
          title: (detail['vartype'] == '1') ? Container(
            width: 50,height: 50,
            decoration: BoxDecoration(
                color: hexToColor(detail['varvalue'][i]),
                borderRadius: BorderRadius.circular(10)
            ),
          ) : Text(detail['varvalue'][i]),
          value: detail['sellerid'].toString() + '-' + detail['varid'].toString() + '-' + detail['varvalue'][i].replaceFirst('#',''),
          onChanged: (val) {setState(() {
            _selectedVar = val;
            //print(_selectedVar);
          });}
      ));

    }
    //if(incList.length > 10) list.add();
    return varlist;
  }
  toggleFav(productID) async{
    var userInfo = await AuthService.getUserInfo();
    if(userInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ابتدا وارد حساب کاربری خود شوید',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.orange,
          )
      );
      // error
    }else {
      Map response = await AuthService.sendDataToServer({'id': "${productID}"}, 'toggleFavorite');
      if(response != null)
        setState(() {
          isFavorite = response['result']['data']['fav'];
        });
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    //_getPDetail();
    //_getCCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _asyncLoader = new AsyncLoader(
      key: _asyncLoaderState,
      initState: () async {
        await _getPDetail();
        await _getCCount();
      },
      renderLoad: () => Center(child: CircularProgressIndicator(),),
      renderError: ([error]) => Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontSize: 16),),
          FlatButton(
              color: Const.LayoutColor,
              child: Text("تلاش دوباره", style: TextStyle(color: Colors.white),),
              onPressed: () => _asyncLoaderState.currentState.reloadState())
        ],
      )),
      renderSuccess: ({data}) => Stack(
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border(
                  bottom: BorderSide(width: 1.0, color: Colors.black12),
                ),
                //boxShadow: [BoxShadow(color: Colors.green, spreadRadius: 3),],
              ),
              //margin: const EdgeInsets.only(top: 5,bottom: 2,right: 5,left: 5),
              child: ListView(
                children: <Widget>[
                  if(detail['quantity'] == 0) Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('ناموجود',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Const.LayoutColor),),
                      ],
                    ),
                  ),
                  if(detail['quantity'] > 0 && detail['label'] == 'inc') Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('پیشنهاد شگفت انگیز',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Const.LayoutColor),),
                      ],
                    ),
                  ),
                  if(detail['quantity'] > 0 && detail['label'] == 'sale') Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('فروش ویژه',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Const.LayoutColor),),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white
                    ),
                    child: Column(
                        children: [
                          slider,
                          if(detail['gallery'].length > 1) Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: detail['gallery'].map<Widget>((item) {
                              int index = detail['gallery'].indexOf(item);
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _current == index
                                      ? Color.fromRGBO(0, 0, 0, 0.9)
                                      : Color.fromRGBO(0, 0, 0, 0.4),
                                ),
                              );
                            }).toList(),
                          ),
                        ]
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            color: Colors.white
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if(detail['brand'].length > 0) GestureDetector(
                                onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => BrandProductListScreen(id: detail['brandid'])));},
                                child: Text('${detail['brand']['name']}',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Color(0xFF05C0D7),)),
                              ),
                              Text(detail['fa_name'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                              if(detail['varname'] != null) Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                    child: Divider(thickness: 1),
                                  ),
                                  Text('انتخاب ${detail['varname']} : ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10,),
                                  Column(children: CreateVarItem()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if(detail['quantity'] > 0) Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white
                        ),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('فروشنده',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                if(detail['sellers_count'] > 1) GestureDetector(
                                  onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => SellersScreen(productID: detail['id'])));},
                                  child: Text('${detail['sellers_count'] - 1} فروشنده دیگر',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.lightBlueAccent)),
                                ),
                              ],
                            ),
                            SizedBox(height: 15,),
                            GestureDetector(
                              onTap: (){ /*Navigator.push(context, MaterialPageRoute(builder: (context) => SellerProductListScreen(cat: detail['sellerid'])));*/},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(left: 15),
                                        child: Icon(Icons.business_center,color: Colors.black54,size: 28,),
                                      ),
                                      Text(detail['seller_name'],style: TextStyle(fontSize: 17),),
                                    ],
                                  ),
                                  //Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 15),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 12,bottom: 12),
                              child: Divider(height: 2, color: Colors.black26,),
                            ),
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Icon(Icons.shop,color: Colors.black54,size: 28,),
                                ),
                                Text('گارانتی ${detail['warrenty']}',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 12,bottom: 12),
                              child: Divider(height: 2, color: Colors.black26,),
                            ),
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Icon(Icons.check_circle_outline,color: Colors.lightBlueAccent[200],size: 28,),
                                ),
                                Text(detail['delivery'] == 0 ? 'موجود در انبار' : 'ارسال از ${detail['delivery'].toString()} روز کاری',style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if(detail['attrs'] != null && detail['attr'].length > 0) Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('ویژگی های محصول',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                            SizedBox(height: 10,),
                            Column(children: CreateAttrItem()),
                            Padding(
                              padding: EdgeInsets.only(top: 12,bottom: 12),
                              child: Divider(height: 2),
                            ),
                            if(detail['attrs'] != null) GestureDetector(
                              onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => AttrScreen(attr: detail['attrs'])));},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Text('مشخصات فنی',style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                                  ),
                                  Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 17),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if(isLength(detail['description'], 10)) Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('نقد و بررسی',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                            SizedBox(height: 10,),
                            Text(detail['description'].substring(0,180) + '...',style: TextStyle(fontSize: 15)),
                            SizedBox(height: 10,),
                            GestureDetector(
                              onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => DescScreen(text: detail['description'])));},
                              child: Text('ادامه مطلب >',style: TextStyle(color: Colors.lightBlueAccent,fontSize: 16),),
                            ),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                if(detail['adv'].length > 0) Container(
                                  child: SizedBox(
                                    child: Column(
                                      children: <Widget>[
                                        Text('نکات مثبت',style: TextStyle(color: Colors.green),),
                                        Column(children: CreateAdv(),)
                                        //Column(children: ,)
                                      ],
                                    ),
                                  ),
                                ),
                                if(detail['disadv'].length > 0) Container(
                                  child: SizedBox(
                                    child: Column(
                                      children: <Widget>[
                                        Text('نکات منفی',style: TextStyle(color: Colors.red),),
                                        Column(children: CreateDisAdv(),)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('نظرات کاربران',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                if(detail['comment'].length > 4) GestureDetector(
                                  onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => CMListScreen(productID: detail['id'])));},
                                  child: Text('${detail['comment'].length} نظر',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.lightBlueAccent)),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(children: CreateCommentItem(),)
                            ),
                            SizedBox(height: 10,),
                            Text('نظراتان در مورد این کالا را با دیگران به اشتراک بگذارید',style: TextStyle(fontSize: 15)),
                            SizedBox(height: 10,),
                            GestureDetector(
                              onTap: () async{
                                var userInfo = await AuthService.getUserInfo();
                                if(userInfo == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('ابتدا وارد حساب کاربری خود شوید',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
                                        backgroundColor: Colors.orange,
                                      )
                                  );
                                  // error
                                }else Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => AddComment(productID: widget.productID)));
                              },
                              child: Text('ثبت نظر >',style: TextStyle(color: Colors.lightBlueAccent,fontSize: 16),),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 12,bottom: 12),
                              child: Divider(height: 2),
                            ),
                            GestureDetector(
                              onTap: () async{
                                var userInfo = await AuthService.getUserInfo();
                                if(userInfo == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('ابتدا وارد حساب کاربری خود شوید',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
                                        backgroundColor: Colors.orange,
                                      )
                                  );
                                  // error
                                }else Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => AddQuestion(productID: widget.productID)));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Text('سوال خود در مورد این محصول را بپرسید',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                  ),
                                  Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 17),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Text('شناسه کالا:  ${detail['id']}'),
                      ),
                      SizedBox(height: 80,)
                    ],
                  ),
                ],
              )
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
                child: (detail['quantity'] > 0) ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      onPressed: (){
                        if(_selectedVar == '' && (detail['varid'] != null && detail['varid'] > 0)){
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('یک ${detail['varname']} را انتخاب کنید',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
                                backgroundColor: Colors.redAccent,
                              )
                          );
                        }else addToCart(detail['sellerid'].toString(), detail['id'].toString(), _selectedVar.replaceFirst(detail['sellerid'].toString()+'-', ''));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Const.LayoutColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        width: 150,height: 40,
                        padding: EdgeInsets.only(top: 7.5,right: 14),
                        child: Text('افزودن به سبد خرید',style: TextStyle(color:Colors.white,fontSize: 16,fontWeight: FontWeight.w400)),
                      ),
                    ),
                    (detail['discount'] == 0) ? Text(intl.NumberFormat("#,###").format(detail['price']) + ' تومان ',style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),) :
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(intl.NumberFormat("#,###").format(detail['price']),style: TextStyle(fontSize:16,decoration: TextDecoration.lineThrough),),
                            SizedBox(width: 5),
                            Container(
                              width: 33, height: 21,
                              margin: EdgeInsets.only(bottom: 7,top: 4),
                              child: Text(' ' + detail['discount'].toString() + '% ', style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.white),),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Const.LayoutColor,
                              ),
                            ),
                          ],
                        ),
                        Text(intl.NumberFormat("#,###").format(detail['offprice']) + ' تومان ',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 19),),
                      ],
                    )
                  ],
                ) : Center(child: FlatButton(
                  onPressed: (){},
                  child: Container(
                    decoration: BoxDecoration(
                      //color: Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Const.LayoutColor,width: 2)
                    ),
                    height: 50,width: 260,
                    padding: EdgeInsets.only(top: 12,right: 14),
                    child: Text('موجودی محصول به اتمام رسیده است',style: TextStyle(color:Const.LayoutColor,fontSize: 16,fontWeight: FontWeight.bold)),
                  ),
                )),
              ),
            ],
          )
        ],
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(right: 10),
          child: GestureDetector(onTap: (){ Navigator.pop(context); },child: Icon(Icons.close)),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20,top: 15),
            child: GestureDetector(
              onTap: (){ Navigator.pushNamed(context, '/cart'); },
              child: Stack(
                fit: StackFit.loose,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right:8),
                    child: Icon(Icons.shopping_cart),
                  ),
                  if(_ccount > 0) Container(
                    margin: EdgeInsets.only(top: 13,left: 3),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                        color: Const.LayoutColor,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text(_ccount.toString(),style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: GestureDetector(onTap: (){ toggleFav(detail['id']); },child: isFavorite ? Icon(Icons.favorite,color: Const.LayoutColor,) : Icon(Icons.favorite_border,)),
          ),
          PopupMenuButton<String>(
              onSelected: (String choice) async{
                if(choice == 'share') {
                  Share.share(detail['fa_name'] + ' ' + Const.SITE_URL + 'product/' + detail['id'].toString(), subject: '${detail['fa_name']}');
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  /*PopupMenuItem(
                      value: 'chart',
                      child: Row(
                          children: <Widget>[
                            Icon(Icons.show_chart,color: Colors.grey,size: 28),
                            Text('نمودار قیمت')
                          ]
                      )
                  ),*/
                  PopupMenuItem(
                      value: 'share',
                      child: Row(
                          children: <Widget>[
                            Icon(Icons.share,color: Colors.grey,size: 28),
                            Text('به اشتراک گذاری کالا')
                          ]
                      )
                  ),
                ];
              }
          ),
        ],
        elevation: 0,
      ),
      body: RefreshIndicator(child: _asyncLoader,onRefresh: () => _handleRefresh(),),
    );
  }
  Future<Null> _handleRefresh() async {
    _asyncLoaderState.currentState.reloadState();
    return null;
  }
  addToCart(sid, pid, variant) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map response = await AuthService.sendDataToServer({
      "sid": sid,
      "pid": pid,
      "variant": variant,
      "cname": prefs.getInt('user.cname').toString(),
    },'AddToCart');
    if(response == null) { // Connection Failed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Const.LayoutColor,
          )
      );
    }else if(response['status']) {
      Navigator.push (context, MaterialPageRoute( builder: (BuildContext context) => CartScreen() ) );
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['result']['message'],style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Const.LayoutColor,
          )
      );
    }
  }

}
