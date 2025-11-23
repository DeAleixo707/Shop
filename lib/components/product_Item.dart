import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/http_exceptions.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/utils/routes.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  const ProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final scaffoldMess = ScaffoldMessenger.of(context); 
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      title: Text(product.title),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(AppRoute.FORM, arguments: product);
                },
                icon: Icon(Icons.edit,
                    color: Theme.of(context).colorScheme.primary)),
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            title: const Text('Remover Produto'),
                            content:
                                const Text('Deseja mesmo remover o produto?'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('Nao')),
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Sim'))
                            ],
                          )).then((confirmed) async {
                    if (confirmed) {
                      try {
                        await Provider.of<Products>(context, listen: false)
                            .deleteProduct(product);
                      } on HttpException catch (error) {
                       scaffoldMess.showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      }
                    }
                  });
                },
                icon: const Icon(Icons.delete, color: Colors.red))
          ],
        ),
      ),
    );
  }
}
