import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyCustomCard extends StatelessWidget {
  final List<Widget> widgets;

  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;
  const MyCustomCard(this.widgets, {Key? key, this.topLeft=8.0, this.topRight=8.0, this.bottomLeft=8.0, this.bottomRight=8.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(topLeft),topRight: Radius.circular(topRight),bottomLeft: Radius.circular(bottomLeft),bottomRight: Radius.circular(bottomRight),)),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 4.0,

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: widgets,
            ),
          ],
        ),
      ),
    );
  }
}
