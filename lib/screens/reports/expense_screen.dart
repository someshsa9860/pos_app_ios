import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportExpenseScreen extends StatelessWidget {
  const ReportExpenseScreen({Key? key}) : super(key: key);
  static const routeName = '/report-expense';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
