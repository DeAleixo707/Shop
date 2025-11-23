import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exceptions.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/utils/constants.dart';

class Products with ChangeNotifier {
  String? userId;
  String? token;
  final _baseUrl = ('${Constants.BASE_API_URL}/products');

 List<Product> _items = [];

  Products([this.token, this.userId, this._items = const [] ]);

  List<Product> get items => [..._items];
  List<Product> get favoriteItems =>
      _items.where((product) => product.isFavorite).toList(); 

  Future<void> loadProducts() async {
    final response = await http.get(Uri.parse("$_baseUrl.json?auth=$token"));
    Map<String, dynamic> data = json.decode(response.body);
    final favResposne = await http.get(
        Uri.parse('${Constants.BASE_API_URL}/userFavorites/$userId.json?auth=$token'));
    final favMap = json.decode(favResposne.body);
    _items.clear();
    data.forEach((productId, productData) {
      final isFavorite = favMap == null ? false : favMap[productId] ?? false;
      _items.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl']));
          isFavorite: isFavorite;
    });
    notifyListeners();
      return Future.value();
  }

  // ignore: unused_element
  Future<void> addNewProducts(Product newProduct) async {
    final response = await http.post(Uri.parse("$_baseUrl.json?auth=$token"),
        body: jsonEncode({
          'title': newProduct.title,
          'description': newProduct.description,
          'price': newProduct.price,
          'imageUrl': newProduct.imageUrl,
        }));

    _items.add(Product(
        id: jsonDecode(response.body)['name'],
        title: newProduct.title,
        description: newProduct.description,
        price: newProduct.price,
        imageUrl: newProduct.imageUrl));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    if (product.id == null) {
      return;
    }
    final index = _items.indexWhere((prod) => prod.id == product.id);
    await http.patch(Uri.parse("$_baseUrl/${product.id}.json?auth=$token"),
        body: jsonEncode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
        }));
    if (index >= 0) {
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(Product product) async {
    final index = _items.indexWhere((prod) => prod.id == product.id);
    if (index >= 0) {
      _items.removeAt(index);
      notifyListeners();

      final response = await http.delete(Uri.parse(
        '$_baseUrl/${product.id}.json?auth=$token',
      ));

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
      }
      throw HttpException(msg: 'Ocorreu um erro ao apagar o produto');
    }
  }

  int get itemsCount {
    return _items.length;
  }
}
