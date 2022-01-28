import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportProductPurchaseScreen extends StatelessWidget {
  const ReportProductPurchaseScreen({Key? key}) : super(key: key);
  static const routeName = '/report-product-purchase';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
