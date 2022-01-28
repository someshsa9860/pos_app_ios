import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportActivityLogScreen extends StatelessWidget {
  const ReportActivityLogScreen({Key? key}) : super(key: key);
  static const routeName = '/report-activity-log';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
