import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/utils/routes.dart';

class ProductGridItem extends StatelessWidget {
  const ProductGridItem({super.key});

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: IconButton(
            icon: Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () {
              product.toggleFavorite(
                auth.token ?? '',
                auth.userId ?? '',
              );
            },
          ),
          title: Text(product.title, textAlign: TextAlign.center),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart_outlined,
                color: Theme.of(context).colorScheme.secondary),
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Adicionado com sucesso'),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                    label: 'DESFAZER',
                    textColor: Colors.deepOrange,
                    onPressed: () => cart.removeSingleItem(product.id)),
              ));
              cart.addItem(product);
            },
          ),
        ),
        child: Hero(
          tag: product.id,
          child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoute.PRODUCT_DETAIL,
                  arguments: product,
                );
              },
              child: Image.network(product.imageUrl, fit: BoxFit.cover)),
        ),
      ),
    );
  }
}
//
