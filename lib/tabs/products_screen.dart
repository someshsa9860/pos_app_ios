import 'package:flutter/material.dart';
import 'package:pos_app/data_management/pos_web_links.dart';
import 'package:pos_app/screens/products/brands_screen.dart';
import 'package:pos_app/screens/products/category_screen.dart';
import 'package:pos_app/screens/products/list_screen.dart';
import 'package:pos_app/screens/products/selling_pr_gr_screen.dart';
import 'package:pos_app/screens/products/units_screen.dart';
import 'package:pos_app/screens/products/variations_screen.dart';
import 'package:pos_app/screens/webview.dart';
import 'package:pos_app/widgets/list_items.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "List Product",
            onClick: () {
              Navigator.pop(context);

              Navigator.of(context).pushNamed(ProductsListScreen.routeName);
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Add Product",
            onClick: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (ctx) => const MyWebView(addProduct)));

              //Navigator.of(context).pushNamed(ProductsAddScreen.routeName);
            }),
        //ContentListItem(
        //     icon: Icons.arrow_right_alt_rounded,
        //     title: "Print Labels",
        //     onClick: () {
        //                            Navigator.pop(context);

        //       Navigator.of(context)
        //           .pushNamed(ProductsPrintLabelScreen.routeName);
        //     }),
        // ContentListItem(
        //     icon: Icons.arrow_right_alt_rounded,
        //     title: "Variation",
        //     onClick: () {
        //                            Navigator.pop(context);

        //       Navigator.of(context)
        //           .pushNamed(ProductsVariationsScreen.routeName);
        //     }),
        // ContentListItem(
        //     icon: Icons.arrow_right_alt_rounded,
        //     title: "Import Products",
        //     onClick: () {
        //                            Navigator.pop(context);

        //       Navigator.of(context).pushNamed(ProductsImportScreen.routeName);
        //     }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Selling Price Group",
            onClick: () {
              Navigator.pop(context);

              Navigator.of(context)
                  .pushNamed(ProductsPriceGroupScreen.routeName);
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Units",
            onClick: () {
              Navigator.pop(context);

              Navigator.of(context).pushNamed(ProductsUnitsScreen.routeName);
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Categories",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(ProductsCategoryScreen.routeName);


            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Brands",
            onClick: () {
              Navigator.pop(context);

              Navigator.of(context).pushNamed(ProductsBrandsScreen.routeName);
            }),
        // ContentListItem(
        //     icon: Icons.arrow_right_alt_rounded,
        //     title: "Warranties",
        //     onClick: () {
        //                            Navigator.pop(context);

        //       Navigator.of(context)
        //           .pushNamed(ProductsWarrantiesScreen.routeName);
        //     }),
      ],
    );
  }
}
