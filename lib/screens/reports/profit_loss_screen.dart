import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportProfitLossScreen extends StatelessWidget {
  const ReportProfitLossScreen({Key? key}) : super(key: key);
  static const routeName = '/report-profit-loss';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
