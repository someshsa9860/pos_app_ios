import 'package:flutter/material.dart';
import 'package:pos_app/screens/home.dart';
import 'package:provider/provider.dart';

import '../app_providers.dart';
import '../routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: getProviders(),
      child: MaterialApp(
        title: 'RENOTECH',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(),
        routes: getRoutes(),
      ),
    );
  }
}
