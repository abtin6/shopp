class Product {
  int id;
  int userId;
  String title;
  String body;
  String image;
  String price;
  String createdAt;
  String updatedAt;

  Product.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    userId = parsedJson['user_id'];
    title = parsedJson['title'];
    body = parsedJson['body'];
    image = parsedJson['image'];
    price = parsedJson['price'];
    createdAt = parsedJson['created_at'];
    updatedAt = parsedJson['updated_at'];
  }

  Map<String, dynamic> toMap() {
    return <String , dynamic>{
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'image': image,
      'price': price,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}