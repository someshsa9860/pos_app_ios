import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportTrendingProductScreen extends StatelessWidget {
  const ReportTrendingProductScreen({Key? key}) : super(key: key);
  static const routeName = '/report-trending-product';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
