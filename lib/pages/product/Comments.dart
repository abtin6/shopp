import 'package:flutter/material.dart';
import 'package:shopapp/components/CommentList.dart';
import 'package:shopapp/pages/product/AddComment.dart';
import 'package:shopapp/services/authenticate.dart';

class CMListScreen extends StatefulWidget {
  final int productID;

  CMListScreen({Key key, @required this.productID}) : super(key: key);
  @override
  State<StatefulWidget> createState() => CMListScreenState();

}
class CMListScreenState extends State<CMListScreen> with AutomaticKeepAliveClientMixin{
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static List<dynamic> detail = [];
  _getComments({int page : 1, bool refresh: false}) async {
    setState(() {
      _isLoading = true;
    });
    Map response = await AuthService.sendDataToServer({'id': widget.productID.toString(), 'page': page.toString()}, 'getComments');
    if(response != null)
      setState(() {
        detail = response['result']['data']['comments'];
        if(detail != null || detail.length > 0) {
          if(refresh) _comments.clear();
          _comments.addAll(detail);
          _currentPage = response['result']['data']['current_page'];
          _isLoading = false;
        }
      });
  }

  List<dynamic> _comments = [];
  int _currentPage = 1;
  bool _isLoading = true;
  ScrollController _listScrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getComments();
    _listScrollController.addListener(() {
      double maxScroll = _listScrollController.position.maxScrollExtent;
      double currentScroll = _listScrollController.position.pixels;
      if(maxScroll - currentScroll <=200) {
        if(! _isLoading) {
          _getComments( page: _currentPage +1);
        }
      }
    });
  }

  Widget streamListView() {
    return _comments.length == 0 && _isLoading
        ? loadingView()
        : _comments.length == 0 ? listIsEmpty()
        : RefreshIndicator(
        child: Container(
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
              color: Colors.grey[200]
          ),
          child: ListView.builder(
              padding: EdgeInsets.only(top:15),
              itemCount: _comments.length,
              itemBuilder: (BuildContext context, int index){
                return CommentList(comment: _comments[index]);
              }
          ),
        ),
        onRefresh: _handleRefresh
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
        body: SafeArea(child: NestedScrollView(
            controller: _listScrollController,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return _comments.length != 0 ?  <Widget>[headList()] : [];
            },
            body: streamListView()
        )),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          var userInfo = await AuthService.getUserInfo();
          if(userInfo == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ابتدا وارد حساب کاربری خود شوید',style: TextStyle(fontFamily: 'Vazir',fontSize: 17),),
                  backgroundColor: Colors.orange,
                )
            );
            // error
          }else Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => AddComment(productID: widget.productID)));},
        child: Icon(Icons.add_comment,color: Colors.white,),
        backgroundColor: Colors.red,
        tooltip: 'ثبت نظر جدید',
      ),
    );
  }

  headList() {
    return SliverAppBar(
      primary: false,
      //automaticallyImplyLeading: false,
      pinned: true,
      backgroundColor: Colors.white,
      title: Text('${_comments.length} دیدگاه',style: TextStyle(fontSize: 16),),
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
        title: Text('بدون دیدگاه',style: TextStyle(fontSize: 16),),
      ),
      body: SafeArea(child: Center(
        child: Text('نظری برای نمایش وجود ندارد'),
      )),
    );
  }
  Future<Null> _handleRefresh() async{
    await _getComments(refresh: true);
    //return Null;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}