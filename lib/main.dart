  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:shop/providers/auth.dart';
import 'package:shop/utils/custom_route.dart';
  import 'package:shop/views/auth_Home_Screen.dart';
  import 'package:shop/views/product_Screen.dart';
  import 'package:shop/providers/cart.dart';
  import 'package:shop/providers/orders.dart';
  import 'package:shop/providers/products.dart';
  import 'package:shop/utils/routes.dart';
  import 'package:shop/views/cart_Screen.dart';
  import 'package:shop/views/orders_Screen.dart';
  import 'package:shop/views/product_form_screen.dart';
  import 'views/product_detail_screen.dart';

 
    void main() async {
    WidgetsFlutterBinding.ensureInitialized(); 
    runApp(const MyApp());
  }
  

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (_) => Products(),
            update: (ctx, auth, previousProducts) =>
                Products(auth.token ?? '',auth.userId?? '',  previousProducts?.items ?? []),
          ),
          ChangeNotifierProvider(
            create: (_) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (_) => Orders(),
            update: (ctx, auth, previousOrders) =>
                Orders(auth.token, auth.userId, previousOrders?.items ?? []),
          ),
        ],
        child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
              ).copyWith(
                secondary:
                    Colors.deepOrange, // This is used for the secondary color
              ),
              secondaryHeaderColor: Colors.deepOrange,
              fontFamily: 'Lato',
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CustomPageTransitionBuilder(),
                  TargetPlatform.iOS: CustomPageTransitionBuilder(),
                },
              ),
            ),
            
            home: AuthHomeScreen(),
            routes: {
              AppRoute.PRODUCT_DETAIL: (ctx) => ProductDetailScreen(),
              AppRoute.CART: (ctx) => CartScreen(),
              AppRoute.ORDERS: (ctx) => OrdersScreen(),
              AppRoute.PRODUCTS: (ctx) => ProductScreen(),
              AppRoute.FORM: (ctx) => ProductFormScreen()
            }),
      );
    }
  }
