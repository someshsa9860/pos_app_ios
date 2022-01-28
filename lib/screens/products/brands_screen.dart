import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ProductsBrandsScreen extends StatelessWidget {
  const ProductsBrandsScreen({Key? key}) : super(key: key);
  static const routeName = '/products-brands';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
