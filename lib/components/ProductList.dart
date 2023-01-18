import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shopapp/pages/product/Index.dart';
import 'package:shopapp/constants.dart' as Const;

class ProductList extends StatelessWidget {
  final product;
  ProductList({@required this.product});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {Navigator.push(context, MaterialPageRoute( builder: (BuildContext context) => ProductScreen(productID: product['id'])));},
      child: Container(
        margin: EdgeInsets.only(right: 5,bottom: 10, left: 5),
        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          border: Border.all(
              width: 1.0, color: Colors.black12
          ),
          //boxShadow: [BoxShadow(color: Colors.green, spreadRadius: 3),],
        ),
        child: (product['discount'] > 0) ? Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            CachedNetworkImage(
              height: 100,
              imageUrl: product['image'],
              placeholder: (context, url) => Image(
                width: 80,
                image: AssetImage('assets/images/placeholder-image.png'),
                fit: BoxFit.cover,
              ),
              fit: BoxFit.cover,
              //errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Text(product['name'],style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500)),
            if(product['quantity'] == 0) Text('اتمام موجودی',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Colors.red)),
            if(product['quantity'] > 0) Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 33, height: 21,
                  child: Text(' ' + product['discount'].toString() + '% ', style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.white),),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Const.LayoutColor,
                  ),
                ),
                Text(intl.NumberFormat("#,###").format(product['offprice']) + ' تومان ',style: TextStyle(fontWeight: FontWeight.w500),)
              ],
            ),
            if(product['quantity'] > 0) Align(
              alignment: Alignment.centerLeft,
              child: Text(intl.NumberFormat("#,###").format(product['price']),style: TextStyle(decoration: TextDecoration.lineThrough),),
            ),
          ],
        ) : Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            CachedNetworkImage(
              height: 100,
              imageUrl: product['image'],
              placeholder: (context, url) => Image(
                width: 80,
                image: AssetImage('assets/images/placeholder-image.png'),
                fit: BoxFit.cover,
              ),
              fit: BoxFit.cover,
              //errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Text(product['name'],style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500)),
            if(product['quantity'] == 0) Text('اتمام موجودی',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Colors.red)),
            if(product['quantity'] > 0) Align(
              alignment: Alignment.centerLeft,
              child: Text(intl.NumberFormat("#,###").format(product['offprice']) + ' تومان ',style: TextStyle(fontWeight: FontWeight.w500),)
            ),
          ],
        )
      ),
    );
  }

}