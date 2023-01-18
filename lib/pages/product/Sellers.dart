import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/pages/shipping/cart.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:shopapp/constants.dart' as Const;
import 'package:intl/intl.dart' as intl;

class SellersScreen extends StatefulWidget {
  final int productID;

  SellersScreen({Key key, @required this.productID}) : super(key: key);
  @override
  State<StatefulWidget> createState() => SellersScreenState();

}
class SellersScreenState extends State<SellersScreen>{
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedVar = '';

  static List<dynamic> detail = [];
  _getSellers() async {
    Map response = await AuthService.sendDataToServer({'id': widget.productID.toString()}, 'getProductSellers');
    if(response != null)
      setState(() {
        detail = response['result']['data'];
      });
  }
  Color hexToColor(String hexString, {String alphaChannel = 'FF'}) {
    return Color(int.parse(hexString.replaceFirst('#', '0x$alphaChannel')));
  }
  List<Container> CreateAttrItem() {
    List<Container> list = []; // attr widget
    if(detail != null){
      for (var i = 0; i < detail.length; i++) {
        List<RadioListTile> CreateVarItem() {
          List<RadioListTile> varlist = []; // incs widget
          varlist.clear();
          for (var d = 0; d < detail[i]['varvalue'].length; d++) {
            varlist.add(RadioListTile(
                groupValue: _selectedVar,
                title: (detail[i]['vartype'] == '1') ? Container(
                  width: 50,height: 50,
                  decoration: BoxDecoration(
                      color: hexToColor(detail[i]['varvalue'][d]),
                      borderRadius: BorderRadius.circular(10)
                  ),
                ) : Text(detail[i]['varvalue'][d]),
                value: detail[i]['sellerid'].toString() + '-' + detail[i]['varid'].toString() + '-' + detail[i]['varvalue'][d].replaceFirst('#',''),
                onChanged: (val) {setState(() {
                  _selectedVar = val;
                });}
            ));
          }
          //if(incList.length > 10) list.add();
          return varlist;
        }
        list.add(Container(
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
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
                        Text(detail[i]['seller_name'],style: TextStyle(fontSize: 17),),
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
                  Text('گارانتی ${detail[i]['warrenty']}',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
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
                  Text(detail[i]['delivery'] == 0 ? 'موجود در انبار' : 'ارسال از ${detail[i]['delivery'].toString()} روز کاری',style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                ],
              ),
              if(detail[i]['varname'] != null) Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: Divider(thickness: 1),
                  ),
                  Text('انتخاب ${detail[i]['varname']} : ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                  SizedBox(height: 10,),
                  Column(children: CreateVarItem()),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left:8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      onPressed: (){
                        if(_selectedVar == '' && (detail[i]['varid'] != null || detail[i]['varid'] > 0)){
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('یک ${detail[i]['varname']} را انتخاب کنید',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
                                backgroundColor: Colors.redAccent,
                              )
                          );
                        }else addToCart(detail[i]['sellerid'].toString(), detail[i]['id'].toString(), _selectedVar.replaceFirst(detail[i]['sellerid'].toString()+'-', ''));
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
                    (detail[i]['discount'] == 0) ? Text(intl.NumberFormat("#,###").format(detail[i]['price']),style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),) :
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(intl.NumberFormat("#,###").format(detail[i]['price']),style: TextStyle(fontSize:16,decoration: TextDecoration.lineThrough),),
                            SizedBox(width: 5),
                            Container(
                              width: 33, height: 21,
                              margin: EdgeInsets.only(bottom: 7,top: 4),
                              child: Text(' ' + detail[i]['discount'].toString() + '% ', style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.white),),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Const.LayoutColor,
                              ),
                            ),
                          ],
                        ),
                        Text(intl.NumberFormat("#,###").format(detail[i]['offprice']) + ' تومان ',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 19),),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
      }
    }
    //if(incList.length > 10) list.add();
    return list;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getSellers();
  }

  @override
  Widget build(BuildContext context) {
    if(detail == null || detail.length == 0)
      return Scaffold(body: Center(child: CircularProgressIndicator(),),);
    else
      return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(
          title: Text(detail.length.toString() + ' فروشنده '),
          backgroundColor: Const.LayoutColor,
        ),
        body: Container(
          color: Colors.grey[200],
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          child: ListView(
            children: CreateAttrItem(),
          ),
        ),
    );
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
            backgroundColor: Colors.red,
          )
      );
    }else if(response['status']) {
      Navigator.push (context, MaterialPageRoute( builder: (BuildContext context) => CartScreen() ) );
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