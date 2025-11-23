import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_Drawer.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/components/badge.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/utils/routes.dart';
import '../components/product_grid.dart';

enum FilterOPtions { Favorite, All }

class ProductOverviewPage extends StatefulWidget {
  const ProductOverviewPage({super.key});

  @override
  State<ProductOverviewPage> createState() => _ProductOverviewPageState();
}

class _ProductOverviewPageState extends State<ProductOverviewPage> {
  Future<void> _refreshProduct(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    await Provider.of<Products>(context, listen: false).loadProducts();
    setState(() {
      isLoading = false;
    });
  }

  bool _showFavoriteOnly = false;
  bool isLoading = true;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      Provider.of<Products>(context, listen: false).loadProducts().then((_) {
        setState(() {
          isLoading = false;
        });
      });
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            PopupMenuButton(
              onSelected: (FilterOPtions filterOptions) {
                setState(() {
                  _showFavoriteOnly = filterOptions == FilterOPtions.Favorite;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: FilterOPtions.Favorite,
                  child: Text("Mostrar favoritados"),
                ),
                const PopupMenuItem(
                  value: FilterOPtions.All,
                  child: Text("Mostrar todos"),
                )
              ],
            ),
            Consumer<Cart>(
              builder: (_, cart, child) => Badged(
                value: cart.itemCount.toString(),
                color: Colors.red,
                child: child!,
              ),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoute.CART);
                  print("Carrinho clicado");
                },
              ),
            ),
          ],
          title: const Text('Minha Loja'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        drawer: const AppDrawer(),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshProduct(context),
                child: ProductGrid(_showFavoriteOnly)));
  }
}
