import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ProductsVariationsScreen extends StatelessWidget {
  const ProductsVariationsScreen({Key? key}) : super(key: key);
  static const routeName = '/products-variations';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
