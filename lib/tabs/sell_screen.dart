import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class SellScreen extends StatelessWidget {
  static const routeName = '/sell';

  const SellScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Sell'),
      ),
      drawer: AppDrawer(),
    );
  }
}
