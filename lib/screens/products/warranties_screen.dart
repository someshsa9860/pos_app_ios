import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ProductsWarrantiesScreen extends StatelessWidget {
  const ProductsWarrantiesScreen({Key? key}) : super(key: key);
  static const routeName = '/expenses-add';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
