import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportSellRepresentativeScreen extends StatelessWidget {
  const ReportSellRepresentativeScreen({Key? key}) : super(key: key);
  static const routeName = '/report-sell-representative';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
