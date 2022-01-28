import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportPurchaseSellScreen extends StatelessWidget {
  const ReportPurchaseSellScreen({Key? key}) : super(key: key);
  static const routeName = '/report-purchase-sell';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
