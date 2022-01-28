import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportCustrGroupScreen extends StatelessWidget {
  const ReportCustrGroupScreen({Key? key}) : super(key: key);
  static const routeName = '/report-customer-group';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
