import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportItemsScreen extends StatelessWidget {
  const ReportItemsScreen({Key? key}) : super(key: key);
  static const routeName = '/report-items';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
