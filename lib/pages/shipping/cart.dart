import 'package:async_loader/async_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/pages/product/Index.dart';
import 'package:shopapp/pages/profile/Address.dart';
import 'package:shopapp/pages/shipping/payment.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:validators/validators.dart';
import 'package:shopapp/constants.dart' as Const;
import 'package:intl/intl.dart' as intl;

class CartScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CartScreenState();

}
class CartScreenState extends State<CartScreen> {
  static List<dynamic> items = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AsyncLoaderState> _asyncLoaderState = GlobalKey<AsyncLoaderState>();
  int profit = 0;
  int totalPrice = 0;
  int _selectedVar = 0;
  int _shipmentPrice = 0;

  _getCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map response = await AuthService.sendDataToServer({'cname': prefs.getInt('user.cname').toString()}, 'getCartItems');
    if(response != null){
      setState(() {
        items = response['result']['data'];
        if(items.length > 0) {
          for(int i=0; i < items.length; i++) profit += items[i]['profit'];
          for(int i=0; i < items.length; i++) totalPrice += items[i]['offprice'] * items[i]['count'];
        }
      });
    }
  }
  List<RadioListTile> CreateShipItem() {
    List<RadioListTile> varlist = []; // incs widget
    for (var i = 0; i < items[0]['shipment'].length; i++) {
      varlist.add(RadioListTile(
          groupValue: _selectedVar,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(items[0]['shipment'][i]['name'],style: TextStyle(fontWeight: FontWeight.bold),),
              Text(items[0]['shipment'][i]['ceiling'] > totalPrice ? intl.NumberFormat("#,###").format(items[0]['shipment'][i]['price']) + ' تومان ' : 'رایگان',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey),),
            ],
          ),
          value: items[0]['shipment'][i]['id'],
          onChanged: (val) {setState(() {
            totalPrice = totalPrice - _shipmentPrice;
            _selectedVar = val;
            if(items[0]['shipment'][i]['ceiling'] > totalPrice)
              _shipmentPrice = items[0]['shipment'][i]['price'];
            else
              _shipmentPrice = 0;
            totalPrice = totalPrice + _shipmentPrice;
          });}
      ));

    }
    //if(incList.length > 10) list.add();
    return varlist;
  }
  Color hexToColor(String hexString, {String alphaChannel = 'FF'}) {
    return Color(int.parse(hexString.replaceFirst('#', '0x$alphaChannel')));
  }
  Future<Null> _handleRefresh() async {
    items.clear();
    profit = totalPrice = 0;
    _asyncLoaderState.currentState.reloadState();
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    //_getCartItems();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var _asyncLoader = new AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await _getCartItems(),
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
        renderSuccess: ({data}) => RefreshIndicator(
          onRefresh: _handleRefresh,
          child: (items.length == 0) ? Align(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/cart.png'),
              SizedBox(height: 10,),
              Text('سبد خرید شما خالی است.',style: TextStyle(fontSize: 17),),
            ],
          ),
          ) : Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200]
                ),
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(width: 1.0, color: Colors.black12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('ارسال به',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                              if(items[0]['addr'] != null)
                                Text('${items[0]['addr']} ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey),),
                              if(items[0]['addr'] == null || !isLength(items[0]['addr'],1))
                                Text('یک آدرس جدید ثبت کنید',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey),),
                            ],
                          ),
                          PopupMenuButton<String>(
                              onSelected: (String choice) async{
                                if (choice == 'addrlist'){
                                  var userInfo = await AuthService.getUserInfo();
                                  if(userInfo == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('ابتدا وارد حساب کاربری خود شوید',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
                                          backgroundColor: Colors.orange,
                                        )
                                    );
                                    // error
                                  }else
                                    Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => AddressScreen(back: 'cart')));
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem(
                                      value: 'addrlist',
                                      child: Text('لیست آدرس ها',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                                  ),
                                ];
                              }
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text('کالاها',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                              Text('${items.length} کالا',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey),),
                            ],
                          ),
                          PopupMenuButton<String>(
                              onSelected: (String choice) async{
                                if (choice == 'remove') delAllCartItems();
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem(
                                      value: 'remove',
                                      child: Row(
                                          children: <Widget>[
                                            Icon(Icons.delete,color: Colors.red,size: 28),
                                            Text('حذف ${items.length} کالا از سبد خرید',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                                          ]
                                      )
                                  ),
                                ];
                              }
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index){
                        return GestureDetector(
                          onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => ProductScreen(productID: items[index]['pid'])));},
                          child: Container(
                            padding: EdgeInsets.only(top: 10,bottom: 10,left: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if(items[index]['label'] == 'inc') Padding(
                                  padding: const EdgeInsets.only(bottom:8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text('پیشنهاد شگفت انگیز',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Const.LayoutColor),),
                                    ],
                                  ),
                                ),
                                if(items[index]['label'] == 'sale') Padding(
                                  padding: const EdgeInsets.only(bottom:8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text('فروش ویژه',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.red),),
                                    ],
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left:5,bottom: 10),
                                      child: CachedNetworkImage(
                                        height: 110,
                                        imageUrl: Const.SITE_URL + '/images/'+ items[index]['pimg'],
                                        placeholder: (context, url) => Image(
                                          width: 80,
                                          image: AssetImage('assets/images/placeholder-image.png'),
                                          fit: BoxFit.cover,
                                        ),
                                        fit: BoxFit.cover,
                                        //errorWidget: (context, url, error) => Icon(Icons.error),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width - 140,
                                          child: Text(items[index]['pname'],style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500)),
                                        ),
                                        SizedBox(height: 10),
                                        if(!isNull(items[index]['cartvar'])) Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(left: 5),
                                              child: Icon(Icons.ac_unit,color: Colors.grey),
                                            ),
                                            Text(items[index]['varname']+ ' : '),
                                            SizedBox(
                                                width: 30,
                                                child: (items[index]['vartype'] == '1') ? Container(
                                                  height: 15,
                                                  decoration: BoxDecoration(
                                                      color: hexToColor('#'+items[index]['varvalue']),
                                                      borderRadius: BorderRadius.circular(25)
                                                  ),
                                                  //child: Text('www'),
                                                ) : Text(items[index]['varvalue'])
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5,),
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(left: 5),
                                              child: Icon(Icons.shop,color: Colors.grey),
                                            ),
                                            Text('گارانتی ${items[index]['warranty']}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(left: 5),
                                              child: Icon(Icons.business_center,color: Colors.grey),
                                            ),
                                            Text('${items[index]['seller_name']}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(left: 5),
                                              child: Icon(Icons.check_circle_outline,color: Colors.grey),
                                            ),
                                            Text(items[index]['delivery'] == 0 ? 'موجود در انبار' : 'تامین کالا از ${items[index]['delivery'].toString()} روز کاری آینده',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(right:10),
                                      child: Container(
                                        margin: EdgeInsets.only(top: 10),
                                        width: 100,
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(8)
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: (){
                                                if(items[index]['quantity'] == items[index]['count']) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('بیشتر از حداکثر موجودی نمی توانید سفارش بدید',style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Vazir',fontSize: 17),),
                                                        backgroundColor: Colors.red,
                                                      )
                                                  );
                                                }else {
                                                  addToCartItem(items[index]['pid'], items[index]['sid'], index, (items[index]['cartvar'] != null) ? items[index]['cartvar'] : '');
                                                }
                                              },
                                              child: Icon(Icons.add,color: Colors.blueAccent,size: 30,),
                                            ),
                                            Text(items[index]['count'].toString(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                            GestureDetector(
                                              onTap: (){delCartItem(items[index]['pid'], items[index]['sid'], index, (items[index]['cartvar'] != null) ? items[index]['cartvar'] : '' );},
                                              child: Icon( (items[index]['count'] == 1) ? Icons.delete_outline : Icons.remove,color: Colors.red,size: 30,),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    (items[index]['discount'] == 0) ? Text(intl.NumberFormat("#,###").format(items[index]['price'] * items[index]['count']) + ' تومان ',style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),) :
                                    Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text(intl.NumberFormat("#,###").format(items[index]['price']),style: TextStyle(fontSize:16,decoration: TextDecoration.lineThrough),),
                                            SizedBox(width: 5),
                                            Container(
                                              width: 33, height: 21,
                                              margin: EdgeInsets.only(bottom: 7,top: 4),
                                              child: Text(' ' + items[index]['discount'].toString() + '% ', style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.white),),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: Const.LayoutColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(intl.NumberFormat("#,###").format(items[index]['offprice'] * items[index]['count']) + ' تومان ',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 19),),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                      margin: EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(width: 1.0, color: Colors.black12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('شیوه ارسال',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          SizedBox(height: 15),
                          Column(children: CreateShipItem()),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                      margin: EdgeInsets.only(top: 15),
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
                              Text('خلاصه سبد',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
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
                              (_selectedVar == 0) ? Text('وابسته به انتخاب',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey),)
                                  : Text((_shipmentPrice == 0) ? 'رایگان' : intl.NumberFormat("#,###").format(_shipmentPrice) + ' تومان ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
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
                    Padding(
                        padding: EdgeInsets.only(top: 20,right: 10,left: 10,bottom: 80),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.info_outline,color: Colors.black54,size: 35,),
                            SizedBox(width: 10,),
                            Expanded(child: Text('کالاهای موجود در سبد شما ثبت و رزرو نشده اند، برای ثبت سفارش مراحل بعدی را تکمیل کنید',style: TextStyle(fontSize: 17,color: Colors.black87,fontWeight: FontWeight.w500),))
                          ],
                        )
                    )
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

                              if(userInfo == null ) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('ابتدا وارد حساب کاربری خود شوید',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
                                      backgroundColor: Colors.orange,
                                    )
                                );
                                // error
                              }else if (items[0]['addr'] == null || !isLength(items[0]['addr'],1) ){
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('آدرس ارسال را انتخاب کنید',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
                                      backgroundColor: Colors.lightBlue,
                                    )
                                );
                              }else if(_selectedVar == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('شیوه ارسال را انتخاب کنید',style: TextStyle(fontFamily: 'Vazir',fontSize: 17,fontWeight: FontWeight.bold),),
                                      backgroundColor: Colors.lightBlue,
                                    )
                                );
                              }else Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => PaymentScreen(shipmentID: _selectedVar, shipmentPrice: _shipmentPrice)));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Const.LayoutColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              width: 150,height: 45,
                              padding: EdgeInsets.only(top: 8.5,right: 17),
                              child: Text('ادامه فرایند خرید',style: TextStyle(color:Colors.white,fontSize: 18,fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Text(intl.NumberFormat("#,###").format(totalPrice) + ' تومان ',style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),),
                        ],
                      )
                  ),
                ],
              )
            ],
          ),
        )
    );
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('سبد خرید',style: TextStyle(fontSize: 18),),
      ),
      body: _asyncLoader
    );
  }
  void delAllCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map response = await AuthService.sendDataToServer({'cname': prefs.getInt('user.cname').toString()}, 'delCartItems');
    if(response == null) { // Connection Failed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }else if(response['status']) {
      setState(() {
        items.clear();
      });
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['result']['message'],style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }
  }
  void delCartItem(pid,sid, index, variant) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map response = await AuthService.sendDataToServer({
      'cname': prefs.getInt('user.cname').toString(),
      'sid': sid.toString(),
      'pid': pid.toString(),
      'variant': variant,
    }, 'delCartItem');
    if(response == null) { // Connection Failed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }else if(response['status']) {
      setState(() {
        profit = profit - items[index]['profit'];
        totalPrice = totalPrice - items[index]['offprice'];
        if(items[index]['count'] == 1) items.removeAt(index); else items[index]['count'] -= 1;
      });
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['result']['message'],style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }
  }
  void addToCartItem(pid,sid, index, variant) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map response = await AuthService.sendDataToServer({
      'cname': prefs.getInt('user.cname').toString(),
      'sid': sid.toString(),
      'pid': pid.toString(),
      'variant': variant,
    }, 'addToCartItem');
    if(response == null) { // Connection Failed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در برقراری ارتباط با سرور',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
            backgroundColor: Colors.red,
          )
      );
    }else if(response['status']) {
      setState(() {
        profit += items[index]['profit'];
        totalPrice += items[index]['offprice'];
        items[index]['count'] += 1;
      });
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