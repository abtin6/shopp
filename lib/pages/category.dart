import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:shopapp/models/category.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:dynamic_treeview/dynamic_treeview.dart';

import 'categoryProducts.dart';


class CategoryScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CategoryScreenState();

}
class CategoryScreenState extends State<CategoryScreen> {
  static List<dynamic> catList = [];
  final GlobalKey<AsyncLoaderState> _asyncLoaderState = GlobalKey<AsyncLoaderState>();

  _getCategories() async {
    Map response = await AuthService.sendDataToServer({}, 'getCategories');
    if(response != null)
      setState(() {
        catList = response['result']['data'];
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _asyncLoader = new AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await _getCategories(),
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
        renderSuccess: ({data}) => SafeArea(child: DynamicTreeView(
          data: getData(),
          config: Config(
              parentTextStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              rootId: "0",
              parentPaddingEdgeInsets:
              EdgeInsets.only(right: 16, top: 0, bottom: 0)),
          onTap: (m) {
            print("onChildTap -> $m");
            Navigator.push(context,MaterialPageRoute(builder: (context) => CategoryProductListScreen(cat: m,)));
          },
          width: MediaQuery.of(context).size.width,
        ))
    );
    return Scaffold(
      body: _asyncLoader,
    );
  }
  List<BaseData> getData(){
    List<BaseData> output = <CategoryModel>[];
    for(int i=0; i < catList.length; i++){
      output.add(CategoryModel(
        id: catList[i]['id'],
        name: catList[i]['title'],
        parentId: catList[i]['parent'],
        extras: {'slug': catList[i]['slug']},
      ));
    }
    return output;
  }
}
