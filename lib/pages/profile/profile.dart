import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/models/user.dart';
import 'package:shopapp/pages/profile/AccountInfo.dart';
import 'package:shopapp/pages/profile/Comment.dart';
import 'package:shopapp/pages/profile/Favorite.dart';
import 'package:shopapp/pages/profile/GiftCard.dart';
import 'package:shopapp/pages/profile/OrderScreen.dart';
import 'package:shopapp/services/authenticate.dart';

import 'Address.dart';

class ProfileScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => ProfileScreenState();
}
class ProfileScreenState extends State<ProfileScreen> {
  UserInfo userInfo;
  final GlobalKey<AsyncLoaderState> _asyncLoaderState = GlobalKey<AsyncLoaderState>();

  _fetchUser() async{
    var response = await AuthService.getUserInfo();
    setState(() {
      userInfo = userInfoFromJson(response.toString());
    });
  }

  @override
    void initState(){
      // TODO: implement initState
      super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var _asyncLoader = new AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await _fetchUser(),
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
        renderSuccess: ({data}) => Container(
          decoration: BoxDecoration( color: Colors.white,),
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
            //alignment: Alignment.bottomCenter,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(onTap: (){ Navigator.pushReplacementNamed(context, '/home');},child: Icon(Icons.home,color: Color(0xFF424750))),
                    //GestureDetector(onTap: (){ Navigator.pushReplacementNamed(context, '/setting');},child: Icon(Icons.settings,color: Color(0xFF424750))),
                    GestureDetector(onTap: (){ logOut(); },child: Icon(Icons.exit_to_app,color: Color(0xFF424750),)),
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(userInfo.name,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                      Text(userInfo.tel,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                    ],
                  )
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Text('سفارشات من',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                          width: 100, height: 100,
                          //margin: EdgeInsets.symmetric(horizontal: 4.0),
                          padding: EdgeInsets.only(left: 3),
                          child: makeOrderButton(index)
                      );
                    }
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Divider(),
                      GestureDetector(
                        onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => FavoriteScreen()));},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Icon(Icons.favorite_border,color: Colors.black87,size: 28,),
                                ),
                                Text('لیست مورد علاقه',style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 17),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 12,bottom: 12),
                        child: Divider(height: 2, color: Colors.black26,),
                      ),
                      GestureDetector(
                        onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => CommentScreen()));},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Icon(FontAwesomeIcons.comment),
                                ),
                                Text('نقد و نظرات',style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 17),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 12,bottom: 12),
                        child: Divider(height: 2, color: Colors.black26,),
                      ),
                      GestureDetector(
                        onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => AddressScreen()));},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Icon(Icons.map,color: Colors.black87,size: 28),
                                ),
                                Text('آدرس ها',style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 17),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 12,bottom: 12),
                        child: Divider(height: 2, color: Colors.black26,),
                      ),
                      GestureDetector(
                        onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => GiftCardScreen()));},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Icon(Icons.credit_card,color: Colors.black87,size: 28),
                                ),
                                Text('کارت های هدیه',style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 17),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 12,bottom: 12),
                        child: Divider(height: 2, color: Colors.black26,),
                      ),
                      GestureDetector(
                        onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => AccountInfoScreen())); },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Icon(Icons.account_box,color: Colors.black87,size: 28),
                                ),
                                Text('اطلاعات حساب کاربری',style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 17,),
                          ],
                        ),
                      ),
                    ],
                  )
              ),

            ],
          ),
        )
    );
      return WillPopScope(
        child: Scaffold(
          //resizeToAvoidBottomPadding: false,
          body: _asyncLoader,
        ),
          onWillPop:  () {
        //trigger leaving and use own data
        Navigator.of(context).pushReplacementNamed('/home');
        //we need to return a future
        return Future.value(false);
      }
      );

  }

  makeOrderButton(index) {
    switch(index){
      case 0:
        return GestureDetector(
          onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => OrderListScreen(index: 0))); },
          child: Image.asset("assets/images/order/pending.png",width: 80,height: 80,),
        );
        break;
      case 1:
        return GestureDetector(
          onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => OrderListScreen(index: 1))); },
          child: Image.asset("assets/images/order/inprogress.png"),
        );
        break;
      case 2:
        return GestureDetector(
          onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => OrderListScreen(index: 2))); },
          child: Image.asset("assets/images/order/delivered.png"),
        );
        break;
      case 3:
        return GestureDetector(
          onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => OrderListScreen(index: 3))); },
          child: Image.asset("assets/images/order/canceled.png"),
        );
        break;
      case 4:
        return GestureDetector(
          onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => OrderListScreen(index: 4))); },
          child: Image.asset("assets/images/order/backed.png"),
        );
        break;
    }
  }
  void logOut() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user.api_token');
    Navigator.of(context).pushReplacementNamed('/login');
  }

}