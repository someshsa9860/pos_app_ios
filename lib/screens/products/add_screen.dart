import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ProductsAddScreen extends StatelessWidget {
  const ProductsAddScreen({Key? key}) : super(key: key);
  static const routeName = '/products-add';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
