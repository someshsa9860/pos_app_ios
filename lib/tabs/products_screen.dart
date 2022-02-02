import 'package:flutter/material.dart';
import 'package:pos_app/screens/products/add_screen.dart';
import 'package:pos_app/screens/products/brands_screen.dart';
import 'package:pos_app/screens/products/categories_screen.dart';
import 'package:pos_app/screens/products/imports_screen.dart';
import 'package:pos_app/screens/products/list_screen.dart';
import 'package:pos_app/screens/products/print_label_screen.dart';
import 'package:pos_app/screens/products/selling_pr_gr_screen.dart';
import 'package:pos_app/screens/products/units_screen.dart';
import 'package:pos_app/screens/products/variations_screen.dart';
import 'package:pos_app/screens/products/warranties_screen.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/list_items.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  static const routeName = '/products';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      drawer: AppDrawer(),
      body: ListView(
        children: [
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "List Product",
              onClick: () {
                Navigator.of(context).pushNamed(ProductsListScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Add Product",
              onClick: () {
                Navigator.of(context).pushNamed(ProductsAddScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Print Labels",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ProductsPrintLabelScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Variation",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ProductsVariationsScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Import Products",
              onClick: () {
                Navigator.of(context).pushNamed(ProductsImportScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Selling Price Group",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ProductsPriceGroupScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Units",
              onClick: () {
                Navigator.of(context).pushNamed(ProductsUnitsScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Categories",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ProductsCategoriesScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Brands",
              onClick: () {
                Navigator.of(context).pushNamed(ProductsBrandsScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Warranties",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ProductsWarrantiesScreen.routeName);
              }),
        ],
      ),
    );
  }
}
