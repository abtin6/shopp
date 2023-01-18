import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/pages/shipping/cart.dart';
import 'package:shopapp/pages/category.dart';
import 'package:shopapp/pages/home.dart';
import 'package:shopapp/pages/product/Index.dart';
import 'package:shopapp/pages/profile/login.dart';
import 'package:shopapp/pages/profile/profile.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:validators/validators.dart';
import 'package:shopapp/constants.dart' as Const;

import 'components/ProductList.dart';

class ShopAppHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ShopAppHomeState();
}

class ShopAppHomeState extends State<ShopAppHome>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  Map<String, AppBar> appBarList;
  String _currentAppBar = 'mainAppBar';
  String currentPageName = 'home';
  FocusNode searchFieldNode;
  final _searchController = TextEditingController();
  final Map<String, Widget> children = <String, Widget>{
    'home': HomePage(),
    'profile': ProfileScreen(),
    'login': LoginScreen(),
    'cart': CartScreen(),
    'category': CategoryScreen(),
  };
  final Map<String, bool> isSelected = <String, bool>{
    'home': true,
    'category': false,
    'cart': false,
    'profile': false,
  };

  // ignore: non_constant_identifier_names
  List SearchResults;

  _getSearchResult(query) async {
    Map response =
    await AuthService.sendDataToServer({'query': query}, 'SearchIn');
    if (response != null)
      setState(() {
        SearchResults = response['result']['data'];
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchFieldNode = FocusNode();
    AppBar mainAppBar = AppBar(
        titleSpacing: 10,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: GestureDetector(
          onTap: () {
            setState(() {
              _currentAppBar = 'searchAppBar';
            });
            searchFieldNode.requestFocus();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xfff0f0f0),
              borderRadius: BorderRadius.circular(3),
            ),
            padding: EdgeInsets.only(top: 8, bottom: 8, right: 8),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.search,
                  color: Color(0xff424750),
                  size: 30,
                ),
                Padding(
                    padding: EdgeInsets.only(right: 15),
                    child: Text( 'جستجو در ' + Const.ApplicationTitle,
                        style:
                        TextStyle(color: Color(0xff8B8F94), fontSize: 16)))
              ],
            ),
          ),
        ));
    AppBar searchAppBar = AppBar(
      title: TextFormField(
        controller: _searchController,
        onChanged: (text) {
          //print("First text field: $text");
          if (isLength(text, 3)) _getSearchResult(text);
          print(SearchResults);
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'جستجو در همه کالاها',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Const.LayoutColor),
          ),
        ),
        focusNode: searchFieldNode,
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: () {
          setState(() {
            _currentAppBar = 'mainAppBar';
            _searchController.text = "";
            SearchResults = null;
          });
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            Icons.arrow_back,
            color: Const.LayoutColor,
          ),
        ),
      ),
    );

    appBarList = <String, AppBar>{
      'mainAppBar': mainAppBar,
      'searchAppBar': searchAppBar,
    };
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _searchController.dispose();
    super.dispose();
  }

  void changeColor(String page) {
    isSelected.forEach((key, value) {
      isSelected[key] = false;
    });
    isSelected[page] = true;
  }

  Future<bool> _onWillPop() {

    if (_searchController.text.length > 0 || _currentAppBar == 'searchAppBar') {
      setState(() {
        _currentAppBar = 'mainAppBar';
        _searchController.text = "";
        SearchResults = null;
      });
    } else {
      setState(() {
        _currentAppBar = 'mainAppBar';
      });
      return showDialog(
          context: context,
          builder: (context) {
            return Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  title: Text('آیا می خواهید از برنامه خارج شوید ؟'),
                  content:
                  Text('با انتخاب گزینه بله از اپلیکیشن خارج می شوید'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'خیر',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                        )),
                    FlatButton(
                        onPressed: () {
                          exit(0);
                        },
                        child: Text(
                          'بله',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ));
          }) ??
          false;
    }
  }

  changePage(String namePage) {
    setState(() {
      currentPageName = namePage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: (currentPageName == 'home' || currentPageName == 'category')
              ? appBarList[_currentAppBar]
              : null,
          body: _currentAppBar == 'mainAppBar'
              ? children[currentPageName]
              : SearchResults == null
              ? Center(
            child: Text('جستجو کنید'),
          )
              : SearchResults.length > 0
              ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 130 / 160
              ),
              padding: EdgeInsets.only(top: 20),
              itemCount: SearchResults.length,
              itemBuilder: (BuildContext context, int index){
                return ProductList(product: SearchResults[index]);
              }
          )
              : Center(
            child: Text('موردی یافت نشد'),
          ),
          bottomNavigationBar: Container(
              color: Colors.white10,
              height: 55.0,
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 8),
              child: BottomAppBar(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    GestureDetector(
                        child: Column(
                          children: <Widget>[
                            Row(children: <Widget>[
                              Icon(Icons.home,
                                  color: (isSelected['home'])
                                      ? Colors.black
                                      : Colors.black54)
                            ]),
                            Row(children: <Widget>[Text('خانه')])
                          ],
                        ),
                        onTap: () {
                          changePage('home');
                          changeColor('home');
                        }),
                    GestureDetector(
                        child: Column(
                          children: <Widget>[
                            Row(children: <Widget>[
                              Icon(Icons.category,
                                  color: (isSelected['category'])
                                      ? Colors.black
                                      : Colors.black54)
                            ]),
                            Row(children: <Widget>[Text('دسته بندی ها')])
                          ],
                        ),
                        onTap: () {
                          changePage('category');
                          changeColor('category');
                        }),
                    GestureDetector(
                        child: Column(
                          children: <Widget>[
                            Row(children: <Widget>[
                              Icon(Icons.shopping_cart,
                                  color: (isSelected['cart'])
                                      ? Colors.black
                                      : Colors.black54)
                            ]),
                            Row(children: <Widget>[Text('سبدخرید')])
                          ],
                        ),
                        onTap: () {
                          changePage('cart');
                          changeColor('cart');
                        }),
                    GestureDetector(
                        child: Column(
                          children: <Widget>[
                            Row(children: <Widget>[
                              Icon(Icons.account_box,
                                  color: (isSelected['profile'])
                                      ? Colors.black
                                      : Colors.black54)
                            ]),
                            Row(children: <Widget>[Text('پروفایل من')])
                          ],
                        ),
                        onTap: () async {
                          SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                          if (prefs.containsKey('user.api_token')) {
                            String apiToken = prefs.getString('user.api_token');
                            var response = await AuthService.sendDataToServer(
                                {"api_token": apiToken}, 'checkApiToken');
                            if (response['status']) {
                              changePage('profile');
                              changeColor('profile');
                            } else {
                              changePage('login');
                              changeColor('profile');
                            }
                          } else {
                            changePage('login');
                            changeColor('profile');
                          }
                        }),
                  ],
                ),
              )),
        ),
        onWillPop: _onWillPop);
  }
}
