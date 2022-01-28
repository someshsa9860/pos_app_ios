import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportRegisterScreen extends StatelessWidget {
  const ReportRegisterScreen({Key? key}) : super(key: key);
  static const routeName = '/report-register';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
