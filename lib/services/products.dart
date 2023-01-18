import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopapp/models/product.dart';

class ProductService {
  // ignore: missing_return
  static Future<Map> getProducts(int page) async {
    return await _getAllProductsFromNetwork(page);
  }

  static Future<Map> _getAllProductsFromNetwork(int page) async {
    final response = await http.get(
        Uri.parse('http://?page=${page}'));

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body)['data'];
      List<Product> products = [];
      responseBody['data'].forEach((item) {
        products.add(Product.fromJson(item));
      });
      return {
        'current_page': responseBody['current_page'],
        'products': products
      };
    }
    return null;
  }
}