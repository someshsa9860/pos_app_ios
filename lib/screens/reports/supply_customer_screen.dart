import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportSupplyCustScreen extends StatelessWidget {
  const ReportSupplyCustScreen({Key? key}) : super(key: key);
  static const routeName = '/report-supply-customer';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
