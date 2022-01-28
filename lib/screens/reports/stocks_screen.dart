import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportStocksScreen extends StatelessWidget {
  const ReportStocksScreen({Key? key}) : super(key: key);
  static const routeName = '/report-stocks';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
