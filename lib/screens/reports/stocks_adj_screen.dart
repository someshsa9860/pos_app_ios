import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportStocksAdjScreen extends StatelessWidget {
  const ReportStocksAdjScreen({Key? key}) : super(key: key);
  static const routeName = '/report-stock-adjustment';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
