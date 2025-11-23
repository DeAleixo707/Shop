import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_Drawer.dart';
import 'package:shop/components/order_item.dart';
import 'package:shop/providers/orders.dart';
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).loadOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Ocorreu um erro',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else {
            return Consumer<Orders>(
              builder: (ctx, orders, child) {
                if (orders.items.isEmpty) {
                  return const Center(child: Text('Nenhum pedido encontrado.'));
                }

                return ListView.builder(
                  itemCount: orders.itemsCount,
                  itemBuilder: (ctx, i) => OrderItem(order: orders.items[i]),
                );
              },
            );
          }
        },
      ),
    );
  }
}
