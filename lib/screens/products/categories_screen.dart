import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ProductsCategoriesScreen extends StatelessWidget {
  const ProductsCategoriesScreen({Key? key}) : super(key: key);
  static const routeName = '/products-categories';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
