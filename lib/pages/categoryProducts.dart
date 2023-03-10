import 'package:flutter/material.dart';
import 'package:shopapp/components/ProductList.dart';
import 'package:shopapp/services/authenticate.dart';
import 'package:shopapp/constants.dart' as Const;

class CategoryProductListScreen extends StatefulWidget {
  final Map cat;

  CategoryProductListScreen({Key key, @required this.cat}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() => CategoryProductListScreenState();

}
class CategoryProductListScreenState extends State<CategoryProductListScreen> with AutomaticKeepAliveClientMixin<CategoryProductListScreen>{
  static List<dynamic> pList = [];

  _getProducts({int page : 1, bool refresh: false}) async {
    setState(() {
      _isLoading = true;
    });
    Map response = await AuthService.sendDataToServer({'id': widget.cat['id'].toString(), 'page': page.toString()}, 'getCategoryProducts');
    if(response != null)
      setState(() {
        pList = response['result']['data']['products'];
        if(pList != null || pList.length > 0) {
          if(refresh) _products.clear();
          _products.addAll(pList);
          _currentPage = response['result']['data']['current_page'];
          _isLoading = false;
        }

      });
    //print(response['products']);
  }

  List<dynamic> _products = [];
  int _currentPage = 1;
  bool _viewStream = false;
  bool _isLoading = true;
  ScrollController _listScrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getProducts();
    _listScrollController.addListener(() {
      double maxScroll = _listScrollController.position.maxScrollExtent;
      double currentScroll = _listScrollController.position.pixels;
      if(maxScroll - currentScroll <=200) {
        if(! _isLoading) {
          _getProducts( page: _currentPage +1);
        }
      }
    });
  }

  Widget moduleListView() {
    return _products.length == 0 && _isLoading
        ? loadingView()
        : _products.length == 0 ? listIsEmpty()
        : RefreshIndicator(
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              childAspectRatio: 130 / 160
            ),
            padding: EdgeInsets.only(top: 20),
            itemCount: _products.length,
            itemBuilder: (BuildContext context, int index){
              return ProductList(product: _products[index]);
            }
        ),
        onRefresh: _handleRefresh
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: NestedScrollView(
          controller: _listScrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return _products.length != 0 ?  <Widget>[headList()] : [];
          },
          body: moduleListView()
      ))
    );
  }

  headList() {
    return SliverAppBar(
      primary: false,
      //automaticallyImplyLeading: false,
      pinned: true,
      backgroundColor: Const.LayoutColor,
      title: Text(widget.cat['title'],style: TextStyle(fontSize: 16),),
      elevation: 3,
    );
  }

  Widget loadingView() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget listIsEmpty() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cat['title'],style: TextStyle(fontSize: 16),),
        backgroundColor: Const.LayoutColor,
      ),
      body: SafeArea(child: Center(
        child: Text('???????????? ???????? ?????????? ???????? ??????????'),
      )),
    );
  }
  Future<Null> _handleRefresh() async{
    await _getProducts(refresh: true);
    //return Null;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
