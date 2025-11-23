import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_Drawer.dart';
import 'package:shop/components/product_Item.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/utils/routes.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  Future<void> _refreshProduct(BuildContext context) {
    return Provider.of<Products>(context, listen: false).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final productItems = productsData.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoute.FORM);
              },
              icon: Icon(Icons.add))
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () =>_refreshProduct(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: productsData.itemsCount,
            itemBuilder: (ctx, i) {
              return ProductItem(
                product: productItems[i],
              );
            },
          ),
        ),
      ),
    );
  }
}
