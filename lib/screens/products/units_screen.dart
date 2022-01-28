import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ProductsUnitsScreen extends StatelessWidget {
  const ProductsUnitsScreen({Key? key}) : super(key: key);
  static const routeName = '/products-units';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
