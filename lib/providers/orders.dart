import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop/providers/cart.dart';
import 'package:shop/utils/constants.dart';

class Order {
  final String id;
  final double total;
  final DateTime dateTime;
  final List<CartItem> products;

  Order({
    required this.id,
    required this.total,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  String? token;
   String? userId;
  final _baseUrl = '${Constants.BASE_API_URL}/orders';

  List<Order> _items = [];
  Orders([this.token, this.userId, this._items = const []]);
  List<Order> get items => [..._items];

  int get itemsCount {
    return _items.length;
  } 

  Future<void> loadOrders() async {
    List<Order> loadedItems = [];
    final response = await http.get(Uri.parse("$_baseUrl/$userId.json?auth=$token"));
    Map<String, dynamic> data = json.decode(response.body);
  
    data.forEach((orderId, orderData) {
    
      loadedItems.add(Order(
        id: orderId,
        dateTime: DateTime.parse(orderData['dateTime']),
        total: orderData['total'],
        products:
            (orderData['products'] as List<dynamic>).map<CartItem>((item) {
          return CartItem(
            id: item['id'],
            productId: item['productId'],
            title: item['title'],
            quantity: item['quantity'],
            price: (item['total'] as num).toDouble(),
          );
        }).toList(),
      ));
    });
    notifyListeners();
      _items = loadedItems.reversed.toList();
    return Future.value();
  }

  Future<void> addOrder(Cart cart) async {
    final dateTime = DateTime.now();
    final response = await http.post(Uri.parse("$_baseUrl/$userId.json?auth=$token"),
        body: jsonEncode({
          'id': Random().nextDouble().toString(),
          'total': cart.totalAmount,
          'dateTime': dateTime.toIso8601String(),
          'products': cart.items.values
              .map((cartItem) => {
                    'id': cartItem.id,
                    'title': cartItem.title,
                    'total': cartItem.price,
                    'quantity': cartItem.quantity,
                    'productId': cartItem.productId
                  })
              .toList(),
        }));
    _items.insert(
      0,
      Order(
        id: jsonDecode(response.body)['name'],
        total: cart.totalAmount,
        products: cart.items.values.toList(),
        dateTime: dateTime,
      ),
    );
    notifyListeners();
  }
}
