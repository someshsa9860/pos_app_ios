import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ProductsImportScreen extends StatelessWidget {
  const ProductsImportScreen({Key? key}) : super(key: key);
  static const routeName = '/products-import';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
