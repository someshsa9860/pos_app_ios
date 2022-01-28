import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportProductSellScreen extends StatelessWidget {
  const ReportProductSellScreen({Key? key}) : super(key: key);
  static const routeName = '/report-product-sell';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
