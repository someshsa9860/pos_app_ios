import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportTaxScreen extends StatelessWidget {
  const ReportTaxScreen({Key? key}) : super(key: key);
  static const routeName = '/report-tax-screen';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
