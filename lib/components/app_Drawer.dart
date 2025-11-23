import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Menu'),
            automaticallyImplyLeading: false, // Remove the back button
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Loja'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed('/'); // Navigate to home
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Pedidos'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed('/orders'); // Navigate to orders
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Produtos'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed('/products'); // Navigate to orders
            },
          ),
             const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Sair'),
            onTap: () {
             Provider.of<Auth>(context, listen: false).logout();
              
            },
          ),
        ],
      ),
    );
  }
}
