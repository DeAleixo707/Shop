import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/cart_item_widget.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/orders.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: true);

    final totalAmount = cart.totalAmount;
    final cartItem = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              elevation: 5,
              margin: EdgeInsets.all(15),
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 20),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(
                          'R\$ $totalAmount',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      ButtonCart(cart: cart)
                    ],
                  ))),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: cart.itemCount,
                  itemBuilder: (ctx, index) => CartItemWidget(
                        cartItem: cartItem[index],
                      )))
        ],
      ),
    );
  }
}

class ButtonCart extends StatefulWidget {
  const ButtonCart({
    super.key,
    required this.cart,
  });

  final Cart cart;

  @override
  State<ButtonCart> createState() => _ButtonCartState();
}

class _ButtonCartState extends State<ButtonCart> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator()
        : TextButton(
            onPressed: widget.cart.totalAmount == 0
                ? null
                : () async {
                    setState(() {
                      isLoading = true;
                    });
                    await Provider.of<Orders>(context, listen: false)
                        .addOrder(widget.cart);
                    setState(() {
                      isLoading = false;
                    });
                    widget.cart.clear();
                  },
            child: const Text('COMPRAR'),
          );
  }
}
